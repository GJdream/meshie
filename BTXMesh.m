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
    }
    
    return self;
}

-(void) sendDataForChannel:(NSString *)channel data:(NSData *)data {
    BTXPayload* payload = [[BTXPayload alloc] init];
    
    payload.uid = [[NSUUID UUID] UUIDString];
    payload.ts = [NSDate date];
    payload.data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    payload.mesh = @"test";
    payload.peerid = @"testid";
    
    [self.payloads addObject:payload];
    [self.btxClientServer broadcastPayload:payload];
}

-(void) onPayloadReceived: (BTXPayload*) payload {
    for(int i = 0; i < self.payloads.count; i++) {
        BTXPayload* p = self.payloads[i];
        if([payload.uid isEqual:p.uid]) {
            return; // We already received this message.
        }
    }
    
    [self.payloads addObject:payload];
    
    // Rebroadcast.  This is gonna cause a lot of noise for each message sent.
    [self.btxClientServer broadcastPayload:payload];
    
    NSLog(@"From %@, Channel %@, Data %@ \a", payload.peerid, payload.mesh, payload.data);
}

@end
