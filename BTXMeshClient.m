//
//  BTXChannel.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXMeshClient.h"

#define ARCHIVE_FILE @"peers.archive"

@interface BTXMeshClient() <BTXCSDelegate>

@property NSDate* lastNearbyUserNotification;

@property NSMutableArray* payloads;
@property NSMutableArray* channels;

@end

@implementation BTXMeshClient

@synthesize peers = _peers;

-(instancetype) init {
    self = [super init];
    if(self) {
        self.btxClientServer = [[BTXClientServer alloc] init];
        self.btxClientServer.delegate = self;
        
        self.payloads = [[NSMutableArray alloc] init];
        self.peers = [NSKeyedUnarchiver unarchiveObjectWithFile:ARCHIVE_FILE];
        
        if(!self.peers) {
            self.peers = [[NSMutableArray alloc] init];
        }
        
        if(!self.channels) {
            self.channels = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

+(BTXMeshClient*) instance {
    static BTXMeshClient* singleInstance = nil;
    if(!singleInstance) {
        singleInstance = [[BTXMeshClient alloc] init];
    }
    
    return singleInstance;
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
    BTXNode* matchedNode = [self findCachedPeer:node];
    NSLog(@"Connection lost with node: %@", node.identifier);

    if (matchedNode) {
        [matchedNode setIsConnected:false];
        NSLog(@"Removed node");
    }
    
    [self.delegate onPeerConnectionStateChanged];
}

-(void) onConnectionEstablishedWithNode:(BTXNode *)node {
    NSLog(@"Connected to node: %@", node.identifier);
    
    // On connection established, broadcast own profile info.
    [self broadcastOwnProfile];
}

-(void) onPayloadReceived: (BTXPayloadWrapper*) payloadWrapper {
    BTXPayload* payload = payloadWrapper.payload;
    
    BOOL isAlreadyReceived = [self isPayloadAlreadyReceived:payload];
    if(isAlreadyReceived) return; // Don't handle the same packet more than once.
    
    BOOL shouldRebroadcast = YES;
    
    [self.payloads addObject:payload]; // Cache the message.
    
    if (payload.type == BTXPayloadProfileResponse) {
        shouldRebroadcast = [self addNewProfileFromPayload:payloadWrapper];
        
        if(shouldRebroadcast) {
            // Do not notify the user more than once every 20 seconds.
            int minWaitTimeSeconds = 20;
            NSTimeInterval lastNotificationSeconds = minWaitTimeSeconds;
            
            // If we have sent a notification before, calculate the time difference.
            if(self.lastNearbyUserNotification) {
                lastNotificationSeconds = [[NSDate date] timeIntervalSinceDate:self.lastNearbyUserNotification];
            }
            if (lastNotificationSeconds >= 20) {
                NSString* message = [NSString stringWithFormat:@"Someone is using Meshie nearby!"];
                
                [self notifyUserForMessage:message];
                // Set current date as the last time a notification has been sent.
                self.lastNearbyUserNotification = [NSDate date];
            }
        }
    }
    
    if(payload.type == BTXPayloadChannelMessage) {
        BTXNode* node = [self findNodeByPeerId:payload.peerid];
        
        if (!node) {
            return;
        }
        
        // If message to self, then change the channel to be the name of the other person.
        if ([payload.mesh isEqualToString:[BTXNode getSelf].displayName]) {
            payload.mesh = node.displayName;
        }
        
        NSString* message = [NSString stringWithFormat:@"%@ - %@", node.displayName, payload.data];
        
        [self notifyUserForMessage:message];
        [self.delegate onMessageReceived:payload.data fromNode:node onChannel:payload.mesh];
    }
    
    if(shouldRebroadcast) {
        // Rebroadcast.  This is gonna cause a lot of noise for each message sent
        // depending on the number of peers connected directly to each other.
        
        [self.btxClientServer broadcastPayload:payload];
    }
}

-(void) notifyUserForMessage: (NSString*) message {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = message;
    localNotif.alertAction = NSLocalizedString(@"View", nil);
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 0;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

// Returns whether we should rebroadcast the profile packet.
-(BOOL) addNewProfileFromPayload: (BTXPayloadWrapper*) payloadWrapper {
    BTXPayload* payload = payloadWrapper.payload;
    
    if (payload.type != BTXPayloadProfileResponse) {
        NSLog(@"ERROR addNewProfileFromPayload: Invalid payload type");
        return false;
    }
    
    NSError* error = nil;
    BTXNode* node = [[BTXNode alloc] initWithString:payload.data error:&error];
    node.peripheralUUID = payloadWrapper.peripheralUUID;
    node.centralUUID = payloadWrapper.centralUUID;
    
    // Ignore self profile broadcasts if they get back to us.
    if([[node identifier] isEqualToString:[[BTXNode getSelf] identifier]]) {
        return NO;
    }
    
    if(error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    if(!node) {
        NSLog(@"Error deserializing node.");
        return NO;
    }
    
    BTXNode* existingNode = [self findCachedPeer:node];
    BOOL isNewNode = existingNode == nil;
    
    if(isNewNode) {
        existingNode = [[BTXNode alloc] init];
    }
    
    if (node.peripheralUUID && (!existingNode.peripheralUUID || ![existingNode.peripheralUUID isEqual:node.peripheralUUID])) {
        existingNode.peripheralUUID = node.peripheralUUID;
    }
    
    if (node.centralUUID && (!existingNode.centralUUID || ![existingNode.centralUUID isEqual:node.centralUUID])) {
        existingNode.centralUUID = node.centralUUID;
    }
    
    // Map fields.
    existingNode.identifier = node.identifier;
    existingNode.about = node.about;
    existingNode.displayName = node.displayName;
    existingNode.mood = node.mood;
    
    existingNode.isConnected = true;
    
    if(isNewNode) {
        [self.peers addObject:existingNode];
    }
    
    [self.delegate onPeerConnectionStateChanged];
    
    return YES;
}

-(void) broadcastOwnProfile {
    BTXNode* selfNode = [BTXNode getSelf];
    NSString* selfNodeJson = [selfNode toJSONString];
    
    BTXPayload* payload = [[BTXPayload alloc] init];
    
    payload.uid = [[NSUUID UUID] UUIDString];
    payload.ts = [NSDate date];
    payload.data = selfNodeJson;
    payload.peerid = selfNode.identifier;
    payload.type = BTXPayloadProfileResponse;
    
    [self.btxClientServer broadcastPayload:payload];
}

-(BTXNode*) findNodeByPeerId:(NSString*) peerId {
    // The current node will not be added as a peer, so check for it.
    if ([peerId isEqualToString:[BTXNode getSelf].identifier]) {
        return [BTXNode getSelf];
    }
    
    BTXNode* tempNode = [[BTXNode alloc] init];
    tempNode.identifier = peerId;
    
    return [self findCachedPeer:tempNode];
}

-(BTXNode*) findCachedPeer: (BTXNode*) node {
    BTXNode* matchedNode = nil;
    for (BTXNode* cachedNode in self.peers) {
        if(cachedNode.identifier && [cachedNode.identifier isEqualToString:node.identifier]) {
            matchedNode = cachedNode;
            break;
        }

        if(cachedNode.peripheralUUID && [cachedNode.peripheralUUID isEqualToString:node.peripheralUUID]) {
            matchedNode = cachedNode;
            break;
        }
        
        if(cachedNode.centralUUID && [cachedNode.centralUUID isEqualToString:node.centralUUID]) {
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

-(NSMutableArray*) peers {
    return _peers;
}

-(void) setPeers:(NSMutableArray *)peers {
    _peers = peers;
}

-(NSArray*) connectedPeers {
    NSMutableArray* p = [[NSMutableArray alloc] init];
    
    for(BTXNode* peer in self.peers) {
        if(peer.isConnected) {
            [p addObject:peer];
        }
    }
    
    return p;
}

// Return an array of packets for a particular channel.
-(NSArray*) messagesForChannel: (NSString*) channelName {
    NSMutableArray* messages = [[NSMutableArray alloc] init];
    
    for(BTXPayload* payload in self.payloads) {
        
        // Skip packets that are not channel messages.
        if(payload.type != BTXPayloadChannelMessage) {
            continue;
        }
        
        if([payload.mesh isEqualToString:channelName]) {
            [messages addObject:payload];
        }
    }
    
    return messages;
}

@end
