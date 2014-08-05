//
//  BTXClientServer.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXClientServer.h"

@implementation BTXClientServer

-(id) init {
    self = [super init];
    if(self) {
        [self initClientServer];
    }
    
    return self;
}

// This should initialize BOTH the central and peripheral managers,
// and synchronize them such that they do not run at the same intervals
// to avoid conflicts and stuff not working.

-(void) initClientServer {
    
#if TARGET_OS_IPHONE
    // Initialize self as peripheral.
    if (!btxPeripheralManager) {
        btxPeripheralManager = [[BTXPeripheralManager alloc] initWithServiceUUID:MSH_SERVICE_UUID characteristicUUID:MSH_TX_UUID];
    }
    
#else
    // Initialize self as central.
    if(!btxCentralManager) {
        btxCentralManager = [[BTXCentralManager alloc] init];
    }
#endif
}



-(void) tick: (NSTimer*) timer {
    //[self writeDataToPeripheral:nil];
}

-(void) preventNewConnections {
    // Prevent connections.
    [btxCentralManager.centralManager stopScan];
    [btxPeripheralManager.peripheralManager stopAdvertising];
}

-(void) allowNewConnections {
    
}

// Broadcast data to currently connected peripherals.
// Broadcast data to currently connected centrals.
-(void) broadcastPayload: (BTXPayload*) payload {
    [self preventNewConnections];
    
    // Serialize to json.
    NSString* json = [payload toJSONString];
    
    // Create broadcast object...
    // buffer data out until complete.
    
    [btxPeripheralManager.broadcastBuffer enqueueData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    [btxPeripheralManager flushBroadcastBuffer];
}

@end
