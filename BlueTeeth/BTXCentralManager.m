//
//  BTXManager.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXCentralManager.h"
#import "BTXGroupedBroadcastBuffer.h"

@interface BTXCentralManager()

@property BTXGroupedBroadcastBuffer* broadcastBuffer;
@property NSString* serviceUUID;
@property NSString* characteristicUUID;

@end

@implementation BTXCentralManager

-(id) init {
    NSLog(@"Call initWithServiceUUID");
    return nil;
}

-(instancetype) initWithServiceUUID:(NSString *)serviceUUID
                 characteristicUUID:(NSString *)characteristicUUID {
    self = [super init];
    if(self) {
        [self initCentralManagerWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
        self.broadcastBuffer = [[BTXGroupedBroadcastBuffer alloc] initWithChunkSize:20];
        
        self.discoveredPeripherals = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) initCentralManagerWithServiceUUID:(NSString *)serviceUUID
                          characteristicUUID:(NSString *)characteristicUUID {
    self.serviceUUID = serviceUUID;
    self.characteristicUUID = characteristicUUID;
    dispatch_queue_t centralQueue = dispatch_queue_create("com.yo.mycentral", DISPATCH_QUEUE_SERIAL);// or however you want to create your dispatch_queue_t
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
}


// Begin scanning for peripherals with the sevices that we are interested in.

-(void) resumeDiscovery {
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self stopDiscovery];
    NSLog(@"Started scanning!!!!!");
    
    [_centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:self.serviceUUID]] options:scanOptions];
}

// Stop scanning.
-(void) stopDiscovery {
    NSLog(@"Stop scanning!!!!!");
    [_centralManager stopScan];
}

-(void) cachePeripheralObject: (CBPeripheral*) peripheral {
    // Cache the peripherals in an array so that they are retained
    // and do not get recycled by ARC.
    
    for (int i = 0; i < self.discoveredPeripherals.count; i++) {
        CBPeripheral* discoveredPeripheral = self.discoveredPeripherals[i];
        if(discoveredPeripheral.identifier == peripheral.identifier) {
            // We already have the peripheral in our array.  Replace the old object with a new one.
            self.discoveredPeripherals[i] = discoveredPeripheral;
            return;
        }
    }
    
    [self.discoveredPeripherals addObject:peripheral];
}

-(void) disconnectPeripheral: (CBPeripheral*) peripheral {
    [self setPeripheralSilencedState:peripheral silence:YES];
    [self.centralManager connectPeripheral:peripheral options:nil];
    // [self removePeripheralFromCache:peripheral];
}

-(void) removePeripheralFromCache: (CBPeripheral*) peripheral {
    for(int i = 0; i < _discoveredPeripherals.count; i++) {
        CBPeripheral* p = _discoveredPeripherals[i];
        if([p.identifier isEqual:peripheral.identifier]) {
            [_discoveredPeripherals removeObjectAtIndex:i];
            break;
        }
    }
    
    [_centralManager cancelPeripheralConnection:peripheral];
}

-(CBCharacteristic*) getCharacteristic:(CBPeripheral*) peripheral
                              uuid:(NSString*) uuid {
    if(peripheral != nil && peripheral.services != nil){
        for(CBService* service in peripheral.services) {
            if(service.characteristics != nil) {
                for(CBCharacteristic* characteristic in service.characteristics) {
                    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:self.characteristicUUID]]) {
                        return characteristic;
                    }
                }
            }
        }
    }

    return nil;
}

// Stop recieving notification from the connected peripheral
-(void) setPeripheralSilencedState: (CBPeripheral*) peripheral
                           silence:(BOOL)silence{
    
    CBCharacteristic* characteristic = [self getCharacteristic:peripheral uuid:self.characteristicUUID];
    if(characteristic) {
        [peripheral setNotifyValue:(!silence) forCharacteristic:characteristic];
    }
}

// BTLE Code
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self resumeDiscovery];
        return;
    }
    
    NSLog(@"Central manager state NOT OK.");
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // If we are already connected to this peripheral.
    for(CBPeripheral* cachedPeripheral in _discoveredPeripherals) {
        if([[cachedPeripheral.identifier UUIDString] isEqualToString:[peripheral.identifier UUIDString]]) {
            return;
        }
    }
    
    NSLog(@"Discovered Peripheral: %@ at %@", peripheral.name, RSSI);
    
//    [self stopDiscovery];
    [self cachePeripheralObject:peripheral];
    [_centralManager connectPeripheral:peripheral options:nil];
}

-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected from peripheral");
    [self disconnectPeripheral:peripheral];
    [self resumeDiscovery];
}

// TODO: handle errors connection and actually connecting successfully.

-(void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to peripheral");
    
    [self disconnectPeripheral:peripheral];
    [self resumeDiscovery];
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Central: Connected");
    [self resumeDiscovery];
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:MSH_SERVICE_UUID]]];
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if(error) {
        [self removePeripheralFromCache:peripheral];
        return;
    }
    NSLog(@"Discovered services");
    for(CBService* service in peripheral.services) {
        NSLog(@"Checking characteristics");

        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:MSH_TX_UUID]] forService:service];
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if(error) {
        [self removePeripheralFromCache:peripheral];
        return;
    }
    
    NSLog(@"Discovered characteristics");

    for(CBCharacteristic* characteristic in service.characteristics) {
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:MSH_TX_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            return;
        }
    }
    
    [self removePeripheralFromCache:peripheral];
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error) {
        NSLog(@"Error in update value for characteristic");
        return;
    }
    
    NSString* str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onDataReceived:fromPeripheral:)]) {
        [self.delegate onDataReceived:characteristic.value fromPeripheral:peripheral];
    }
    
    NSLog(@"Central: Recieved %@", str);
}

/*
    Create tuples of peripheral, id - broadcast buffers...
    Remove peripheral/broadcast buffer tuple when...
        - peripheral's broadcast buffer is cleared
        - peripheral gets disconnected
*/

-(void) broadcastData: (NSData*) data {
    NSArray* connectedPeripherals = _discoveredPeripherals;
    
    // Create separate buffer of data for each connected peripheral
    for(CBPeripheral* peripheral in connectedPeripherals) {
        NSString* key = [peripheral.identifier UUIDString];
        [self.broadcastBuffer enqueueData:data forKey:key];
    }
    
    // Begin flushing out the data on the characteristic we are looking for.
    for(CBPeripheral* peripheral in connectedPeripherals) {
        CBCharacteristic* ch = [self getCharacteristic:peripheral uuid:self.characteristicUUID];
        if(ch) {
            [self flushBufferForPeripheral:peripheral characteristic:ch];
        }
    }
}

-(void) flushBufferForPeripheral:(CBPeripheral*) peripheral
                          characteristic:(CBCharacteristic*) characteristic {
    NSString* key = [peripheral.identifier UUIDString];
    if ([self.broadcastBuffer hasDataForKey:key]) {
        NSData* data = [self.broadcastBuffer peekDataForKey:key];
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if(error) {
        NSLog(@"Error writing characteristic: %@", error);
    } else {
        // If the value that we wrote was successful.
        NSString* key = [peripheral.identifier UUIDString];
        [self.broadcastBuffer markDequeuedForKey:key];
    }
    
    NSString* key = [peripheral.identifier UUIDString];
    if ([self.broadcastBuffer hasDataForKey:key]) {
        // Flush the buffer by peripheral/characteristic.
        [self flushBufferForPeripheral:peripheral characteristic:characteristic];
    }
}


@end
