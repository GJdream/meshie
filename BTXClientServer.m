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

-(void) initClientServer {
    // Initialize self as peripheral.
    if (!btxPeripheralManager) {
        btxPeripheralManager = [[BTXPeripheralManager alloc] initWithServiceUUID:MSH_SERVICE_UUID characteristicUUID:MSH_TX_UUID];
        btxPeripheralManager.delegate = self;
    }
    
    // Initialize self as central.
    if(!btxCentralManager) {
        btxCentralManager = [[BTXCentralManager alloc] initWithServiceUUID:MSH_SERVICE_UUID characteristicUUID:MSH_TX_UUID];
        btxCentralManager.delegate = self;
    }
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

-(void) onConnectionLostWithPeripheral:(CBPeripheral *)peripheral {
    BTXNode* node = [[BTXNode alloc] init];
    node.peripheralUUID = [[peripheral identifier] UUIDString];
    
    [self onConnectionLostWithNode:node];
    
}

-(void) onConnectionLostWithCentral:(CBCentral *)central {
    BTXNode* node = [[BTXNode alloc] init];
    node.centralUUID = [[central identifier] UUIDString];
    
    [self onConnectionLostWithNode:node];
}

-(void) onConnectionEstablishedWithCentral:(CBCentral *)central {
    BTXNode* node = [[BTXNode alloc] init];
    node.centralUUID = [central.identifier UUIDString];
    
    [self onConnectionEstablishedWithNode:node];
}

-(void) onConnectionEstablishedWithPeripheral:(CBPeripheral *)peripheral {
    BTXNode* node = [[BTXNode alloc] init];
    node.peripheralUUID = [peripheral.identifier UUIDString];
    
    [self onConnectionEstablishedWithNode:node];
}

-(void) onConnectionLostWithNode: (BTXNode*) node {
    [self.delegate onConnectionLostWithNode:node];
}

-(void) onConnectionEstablishedWithNode: (BTXNode*) node {
    [self.delegate onConnectionEstablishedWithNode:node];
}

// Returns data sent from the connected peripheral to this central.
-(void) onDataReceived:(NSData*) data
        fromPeripheral:(CBPeripheral*) peripheral {
    // The data may come in twice (over central and peripheral)
    // So, prepend the key with a character to buffer it uniquely.
    NSString* key = [peripheral.identifier UUIDString];
    key = [NSString stringWithFormat:@"P:%@", key];
    
    BOOL bufferComplete = [self.receiveBuffer bufferData:data forKey:key];
    if(bufferComplete) {
        NSData* d = [self.receiveBuffer dataForKey:key];
        [self handlePayloadFromData:d peripheralUUID:[peripheral.identifier UUIDString] centralUUID:nil];
    }
}

// Returns data sent from the central to the current peripehral.
-(void) onDataReceived: (NSData*) data
           fromCentral: (CBCentral*) central {
    
    NSString* key = [central.identifier UUIDString];
    key = [NSString stringWithFormat:@"C:%@", key];
    
    BOOL bufferComplete = [self.receiveBuffer bufferData:data forKey:key];
    if(bufferComplete) {
        NSData* d = [self.receiveBuffer dataForKey:key];
        [self handlePayloadFromData:d peripheralUUID:nil centralUUID:[central.identifier UUIDString]];
    }
}

-(void) handlePayloadFromData: (NSData*) data
               peripheralUUID: (NSString*) peripheralUUID
                  centralUUID: (NSString*) centralUUID {
    NSError* error;
    BTXPayload* payload = [[BTXPayload alloc] initWithData:data error:&error];
    BTXPayloadWrapper* wrapper = [[BTXPayloadWrapper alloc] init];
    
    wrapper.peripheralUUID = peripheralUUID;
    wrapper.centralUUID = centralUUID;
    wrapper.payload = payload;
    
    
    if(error) {
        NSLog(@"Error: %@", error);
    }
    
    if(!payload) return;
    
    [self.delegate onPayloadReceived:wrapper];
}

@end
