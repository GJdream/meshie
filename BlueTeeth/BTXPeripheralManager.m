//
//  BTXPeripheral.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXPeripheralManager.h"
#import "BTXGroupedBroadcastBuffer.h"

@interface BTXPeripheralManager()

@property (nonatomic, strong) BTXGroupedBroadcastBuffer* broadcastBuffer;

@property NSMutableArray* centrals;

@property NSString* serviceUUID;
@property NSString* characteristicUUID;

@end

@implementation BTXPeripheralManager

-(id) init {
    NSLog(@"Call initWithServiceUUID");
    return nil;
}

-(instancetype) initWithServiceUUID:(NSString *)serviceUUID
                 characteristicUUID:(NSString *)characteristicUUID {
    self = [super init];
    if(self) {
        [self initPeripheralManagerWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
        self.broadcastBuffer = [[BTXGroupedBroadcastBuffer alloc] initWithChunkSize:20];
        self.centrals = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) initPeripheralManagerWithServiceUUID:(NSString *)serviceUUID
                          characteristicUUID:(NSString *)characteristicUUID {
    self.serviceUUID = serviceUUID;
    self.characteristicUUID = characteristicUUID;
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

-(void) startAdvertising {
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:self.serviceUUID]] }];
}

-(void) stopAdvertising {
    [self.peripheralManager stopAdvertising];
}

-(void) peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    CBATTRequest *aRequest = requests[0];
    [peripheral respondToRequest:[requests objectAtIndex:0] withResult:CBATTErrorSuccess];
    
    NSData* data = aRequest.value;
    CBCentral* central = aRequest.central;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onDataReceived:fromCentral:)]) {
        [self.delegate onDataReceived:data fromCentral:central];
    }
}

-(void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if(peripheral.state != CBPeripheralManagerStatePoweredOn) {
        for(CBCentral* central in self.centrals) {
            [self.delegate onConnectionLostWithCentral:central];
        }
        
        return;
    }
    
    if(peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:self.characteristicUUID]
                                                                         properties:(CBCharacteristicPropertyNotify | CBCharacteristicPropertyWrite)
                                                                              value:nil
                                                                        permissions:CBAttributePermissionsWriteable | CBAttributePermissionsReadable];
        
        CBMutableService* service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:self.serviceUUID] primary:YES];

        service.characteristics = @[self.transferCharacteristic];

        [_peripheralManager addService:service];
        [self startAdvertising];

        NSLog(@"Added service to peripheral");
    }
}


-(void) peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Peripheral: Connected to central");
    [self.centrals addObject:central];
    
    [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:central];
    
    
    // Create broadcast object...
    // buffer data out until complete.
    //[self broadcastData:[@"TEST" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.delegate onConnectionEstablishedWithCentral:central];
}

-(void) peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central unsubscribed from peripheral");
    [self.centrals removeObject:central];
    [self.delegate onConnectionLostWithCentral:central];
}

-(void) broadcastData: (NSData*) data {
    [self.broadcastBuffer enqueueData:data forKey:@"ALL"];
    [self flushBroadcastBuffer];
}

-(void) flushBroadcastBuffer {
    if(self.transferCharacteristic == nil) return;
    
    while ([self.broadcastBuffer hasDataForKey:@"ALL"]) {
        NSData* d = [self.broadcastBuffer peekDataForKey:@"ALL"];
        BOOL isSuccess = [self.peripheralManager updateValue:d forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if(isSuccess) {
            // If we successfully sent this chunk of data, then dequeue it and try to send next batch of data, if any.
            [self.broadcastBuffer markDequeuedForKey:@"ALL"];
        } else {
            // Otherwise, return and wait to be triggered again by peripheralManagerIsReadyToUpdateSubscribers
            return;
        }
    }
    
    // Resume advertising after data has been sent out.
    [self startAdvertising];
}

-(void) peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self flushBroadcastBuffer];
}

@end
