//
//  BTXChannel.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXMesh.h"

@implementation BTXMesh

-(instancetype) init {
    self = [super init];
    if(self) {
        self.btxClientServer = [[BTXClientServer alloc] init];
    }
    
    return self;
}

-(void) sendDataForChannel:(NSString *)channel data:(NSData *)data {
    // Build the payload...
    
    BTXPayload* payload = [[BTXPayload alloc] init];
    
    payload.ts = [NSDate date];
    payload.d = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.btxClientServer broadcastPayload:payload];
}

-(void) onDataReceivedFromPeer:(BTXPeer *)peer
                       channel:(NSString *)channel
                          data:(NSData *)data {
    
    NSLog(@"From %@, Channel %@, Data %@", peer.identifier, channel, data);
}

@end
