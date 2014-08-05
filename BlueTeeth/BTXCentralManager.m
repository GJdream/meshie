//
//  BTXManager.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXCentralManager.h"

@interface BTXCentralManager()

@end

@implementation BTXCentralManager

-(id) init {
    self = [super init];
    if(self) {
        [self initCentralManager];
    }
    
    return self;
}

-(void) initCentralManager {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _centralManager.delegate = self;
    _discoveredPeripherals = [[NSMutableArray alloc] init];
}

// My Code
-(void) beginScanningForInterestedServices {
    [_centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:MSH_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
}

-(void) cachePeripheralObject: (CBPeripheral*) peripheral {
    for (int i = 0; i < self.discoveredPeripherals.count; i++) {
        CBPeripheral* discoveredPeripheral = self.discoveredPeripherals[i];
        if(discoveredPeripheral.identifier == peripheral.identifier) {
            self.discoveredPeripherals[i] = discoveredPeripheral;
            return;
        }
        
    }
    
    [self.discoveredPeripherals addObject:peripheral];
}

-(void) disconnectPeripheral: (CBPeripheral*) peripheral {
    [self silencePeripheral:peripheral];
    [self removePeripheralFromCache:peripheral];
}

-(void) removePeripheralFromCache: (CBPeripheral*) peripheral {
    for(int i = 0; i < _discoveredPeripherals.count; i++) {
        CBPeripheral* p = _discoveredPeripherals[i];
        if([p.identifier isEqual:peripheral.identifier]) {
            [_discoveredPeripherals removeObjectAtIndex:i];
            break;
        }
    }
}

// Stop recieving notification from the connected peripheral.
-(void) silencePeripheral: (CBPeripheral*) peripheral {
    if(peripheral != nil && peripheral.services != nil){
        for(CBService* service in peripheral.services) {
            if(service.characteristics != nil) {
                for(CBCharacteristic* characteristic in service.characteristics) {
                    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:MSH_TX_UUID]]) {
                        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        return;
                    }
                }
            }
        }
    }
    
    [_centralManager cancelPeripheralConnection:peripheral];
}

// BTLE Code
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self beginScanningForInterestedServices];
        return;
    }
    
    NSLog(@"Central manager state NOT OK.");
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered Peripheral: %@ at %@", peripheral.name, RSSI);
    
    [self cachePeripheralObject:peripheral];
    [_centralManager connectPeripheral:peripheral options:nil];
}


// TODO: handle errors connection and actually connecting successfully.

-(void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to peripheral");
    
    [self disconnectPeripheral:peripheral];
}

-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected from peripheral");
    [self disconnectPeripheral:peripheral];
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    [_centralManager stopScan];
    NSLog(@"Stopped scanning.");
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:MSH_SERVICE_UUID]]];
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if(error) {
        [self silencePeripheral:peripheral];
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
        [self silencePeripheral:peripheral];
        return;
    }
    NSLog(@"Discovered characteristics");

    for(CBCharacteristic* characteristic in service.characteristics) {
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:MSH_TX_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error) {
        NSLog(@"Error in update value for characteristic");
        return;
    }
    
    NSString* str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"Recieved: %@", str);
}

@end
