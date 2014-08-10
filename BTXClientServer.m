//
//  BTXClientServer.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//
#import "BTXReceiveBuffer.h"
#import "BTXClientServer.h"

@interface BTXClientServer() <BTXPCDelegate>

@property BTXReceiveBuffer* receiveBuffer;

@end

@implementation BTXClientServer

-(id) init {
    self = [super init];
    if(self) {
        [self initClientServer];
        self.receiveBuffer = [[BTXReceiveBuffer alloc] initWithChunkSize:20];
    }
    
    return self;
}

// This should initialize BOTH the central and peripheral managers,
// and synchronize them such that they do not run at the same intervals
// to avoid conflicts and stuff not working.

-(void) initClientServer {
    
//#if !TARGET_OS_IPHONE
    // Initialize self as peripheral.
    if (!btxPeripheralManager) {
        btxPeripheralManager = [[BTXPeripheralManager alloc] initWithServiceUUID:MSH_SERVICE_UUID characteristicUUID:MSH_TX_UUID];
        btxPeripheralManager.delegate = self;
    }
    
//#else
    // Initialize self as central.
    if(!btxCentralManager) {
        btxCentralManager = [[BTXCentralManager alloc] initWithServiceUUID:MSH_SERVICE_UUID characteristicUUID:MSH_TX_UUID];
        btxCentralManager.delegate = self;
        
    }
    
    
//#endif
    
}

-(void) pauseDiscoveryAndBroadcasts {
    // Prevent connections.
    return;
    [btxCentralManager.centralManager stopScan];
    [btxPeripheralManager.peripheralManager stopAdvertising];
}

-(void) resumeDiscoveryAndBroadcasts {
    
}

// Broadcast data to currently connected peripherals.
// Broadcast data to currently connected centrals.
-(void) broadcastPayload: (BTXPayload*) payload {
    // Serialize to json.
    NSString* json = [payload toJSONString];
    
    // Broadcast data to all connected peripheral.
    [btxCentralManager broadcastData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Broadcast data to all connected centrals.
    [btxPeripheralManager broadcastData:[json dataUsingEncoding:NSUTF8StringEncoding]];
}

// Returns data sent from the connected peripheral to this central.
-(void) onDataReceived:(NSData*) data
        fromPeripheral:(CBPeripheral*) peripheral {
    // Create peer id if not exists.
    // Look up peer by peripheral id
    
    NSString* key = [peripheral.identifier UUIDString];
    
    BOOL bufferComplete = [self.receiveBuffer bufferData:data forKey:key];
    if(bufferComplete) {
        NSData* d = [self.receiveBuffer dataForKey:key];
        [self handlePayloadFromData:d];
    }
}

// Returns data sent from the central to the current peripehral.
-(void) onDataReceived: (NSData*) data
           fromCentral: (CBCentral*) central {
    // Create peer id.
    // Lookup peer by central id.
    
    NSString* key = [central.identifier UUIDString];
    
    BOOL bufferComplete = [self.receiveBuffer bufferData:data forKey:key];
    if(bufferComplete) {
        NSData* d = [self.receiveBuffer dataForKey:key];
        [self handlePayloadFromData:d];
    }
}

-(void) handlePayloadFromData: (NSData*) data {
    NSError* error;
    BTXPayload* payload = [[BTXPayload alloc] initWithData:data error:&error];
    if(error) {
        NSLog(@"Error: %@", error);
    }
    
    NSLog(@"Data recieved from either central or peripheral: %@", payload.data);
    if(!payload) return;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onPayloadReceived:)]) {
        [self.delegate onPayloadReceived:payload];
    }

}

@end
