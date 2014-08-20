//
//  BTXChannel.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXMesh.h"

@interface BTXMesh() <BTXCSDelegate>

@property NSMutableArray* payloads;

@end

@implementation BTXMesh

-(instancetype) init {
    self = [super init];
    if(self) {
        self.btxClientServer = [[BTXClientServer alloc] init];
        self.btxClientServer.delegate = self;
        
        self.payloads = [[NSMutableArray alloc] init];
        self.peers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) sendDataForChannel:(NSString *)channel data:(NSData *)data {
    BTXPayload* payload = [[BTXPayload alloc] init];
    
    payload.uid = [[NSUUID UUID] UUIDString];
    payload.ts = [NSDate date];
    payload.data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    payload.mesh = channel;
    payload.peerid = [[BTXNode getSelf] identifier];
    payload.type = BTXPayloadChannelMessage;
    
    [self.payloads addObject:payload];
    [self.btxClientServer broadcastPayload:payload];
}

-(void) onConnectionLostWithNode: (BTXNode*) node {
    NSLog(@"Connection lost with node: %@", node.identifier);
    
    BTXNode* matchedNode = [self findCachedPeer:node];
    
    if (matchedNode) {
        [matchedNode setIsConnected:false];
        NSLog(@"Removed node");
    }
}

-(void) onConnectionEstablishedWithNode:(BTXNode *)node {
    NSLog(@"Connected to node: %@", node.identifier);
    
    // On connection established, broadcast own profile info.
    [self broadcastOwnProfile];
}

-(void) onPayloadReceived: (BTXPayload*) payload {
    BOOL isAlreadyReceived = [self isPayloadAlreadyReceived:payload];
    if(isAlreadyReceived) return; // Don't handle the same packet more than once.
    [self.payloads addObject:payload]; // Cache the message.
    
    if (payload.type == BTXPayloadProfileResponse) {
        [self addNewProfileFromPayload:payload];
    }
    
    // Rebroadcast.  This is gonna cause a lot of noise for each message sent
    // depending on the number of peers connected directly to each other.
    [self.btxClientServer broadcastPayload:payload];

    if(payload.type == BTXPayloadChannelMessage) {
        [self.delegate onMessageReceived:payload.data];
    }
    
    NSLog(@"From %@, Channel %@, Data %@ \a", payload.peerid, payload.mesh, payload.data);
}

-(void) addNewProfileFromPayload: (BTXPayload*) payload {
    if (payload.type != BTXPayloadProfileResponse) {
        NSLog(@"ERROR addNewProfileFromPayload: Invalid payload type");
        return;
    }
    NSError* error = nil;
    BTXNode* node = [[BTXNode alloc] initWithString:payload.data error:&error];
    if(error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    if(!node) {
        NSLog(@"Error deserializing node.");
        return;
    }
    
    BTXNode* existingNode = [self findCachedPeer:node];
    
    if(existingNode) {
        NSLog(@"Node already exists.");
        // We should do a data map of some kind...
        // Just so we populate the node with updated info as well as caching old info if needed.
        
        // For example, a node once being connected as a central, then changing to a peripheral.
        // It may be nice to cache both central and peripheral uuids.
        // return;
    }
    [self.peers addObject:node];
}

-(void) broadcastOwnProfile {
    BTXNode* selfNode = [BTXNode getSelf];
    NSString* selfNodeJson = [selfNode toJSONString];
    
    BTXPayload* payload = [[BTXPayload alloc] init];
    
    payload.ts = [NSDate date];
    payload.data = selfNodeJson;
    payload.peerid = [[BTXNode getSelf] identifier];
    payload.type = BTXPayloadProfileResponse;
    
    [self.btxClientServer broadcastPayload:payload];
}

-(BTXNode*) findCachedPeer: (BTXNode*) node {
    BTXNode* matchedNode = nil;
    for (BTXNode* cachedNode in self.peers) {
        if(cachedNode.peripheralUUID && [cachedNode.peripheralUUID isEqualToString:node.peripheralUUID]) {
            matchedNode = cachedNode;
            break;
        }
        
        if(cachedNode.centralUUID && [cachedNode.centralUUID isEqualToString:node.centralUUID]) {
            matchedNode = cachedNode;
            break;
        }
        
        if(cachedNode.identifier && [cachedNode.identifier isEqualToString:node.identifier]) {
            matchedNode = cachedNode;
            break;
        }
    }
    
    return matchedNode;
}

-(BOOL) isPayloadAlreadyReceived: (BTXPayload*) payload {
    for(int i = 0; i < self.payloads.count; i++) {
        BTXPayload* p = self.payloads[i];
        if([payload.uid isEqual:p.uid]) {
            return TRUE; // We already received this message.
        }
    }
    
    return FALSE;
}

@end
