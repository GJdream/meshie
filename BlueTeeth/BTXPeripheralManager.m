//
//  BTXPeripheral.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXPeripheralManager.h"

@interface BTXPeripheralManager()

@property NSString* serviceUUID;
@property NSString* characteristicUUID;

@end

@implementation BTXPeripheralManager

-(id) init {
    self = [super init];
    if(self) {
        NSLog(@"Call initWithServiceUUID");
    }
    
    return self;
}

-(instancetype) initWithServiceUUID:(NSString *)serviceUUID
                 characteristicUUID:(NSString *)characteristicUUID {
    self = [super init];
    if(self) {
        [self initPeripheralManagerWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
        self.broadcastBuffer = [[BTXBroadcastBuffer alloc] initWithChunkSize:20];
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

-(void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if(peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral state not powered on!");
        return;
    }
    
    if(peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:self.characteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        
        CBMutableService* service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:self.serviceUUID] primary:YES];

        service.characteristics = @[self.transferCharacteristic];

        [_peripheralManager addService:service];
        [self startAdvertising];

        NSLog(@"Added service to peripheral");
    }
}

-(void) peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Connected");
    [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:central];
    
    // Create broadcast object...
    // buffer data out until complete.
    
    [self.broadcastBuffer enqueueData:[@"TEST" dataUsingEncoding:NSUTF8StringEncoding]];
    [self flushBroadcastBuffer];
}

-(void) peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central unsubscribed from peripheral");
}

-(void) flushBroadcastBuffer {
    while (self.broadcastBuffer.hasQueuedData) {
        NSData* d = [self.broadcastBuffer peekData];
        BOOL isSuccess = [self.peripheralManager updateValue:d forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if(isSuccess) {
            // If we successfully sent this chunk of data, then dequeue it and try to send next batch of data, if any.
            [self.broadcastBuffer markDequeued];
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
