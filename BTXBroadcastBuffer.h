//
//  BTXBroadcast.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/4/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTXBroadcastBuffer : NSObject

@property BOOL hasQueuedData;
@property NSData* terminatingPattern; // 20 bytes of some random data.

-(instancetype) initWithChunkSize:(NSInteger) size;

-(void) enqueueData: (NSData*) data;
-(NSData*) peekData;
-(void) seek;

@end
