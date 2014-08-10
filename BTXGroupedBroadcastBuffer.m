//
//  BTXGroupedBroadcastBuffer.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/5/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXBroadcastBuffer.h"
#import "BTXGroupedBroadcastBuffer.h"

@interface BTXGroupedBroadcastBuffer()

@property (strong, nonatomic) NSMutableDictionary* dictionary;

@end

@implementation BTXGroupedBroadcastBuffer

NSInteger _chunkSize;

-(instancetype) init {
    return [self initWithChunkSize:20];
}

-(instancetype) initWithChunkSize: (NSInteger) chunkSize {
    self = [super init];
    if(self) {
        self.dictionary = [[NSMutableDictionary alloc] init];
        _chunkSize = chunkSize;
        _createdOn = [NSDate date];
    }
    
    return self;
}

-(BOOL) hasDataForKey: (NSString*) key {
    BTXBroadcastBuffer* broadcastBuffer = [self getBroadcastBufferForKey:key];
    return broadcastBuffer && broadcastBuffer.hasQueuedData;
}

-(void) enqueueData:(NSData *)data forKey:(NSString *)key {
    BTXBroadcastBuffer* broadcastBuffer = [self getBroadcastBufferForKey:key];
    if(!broadcastBuffer) {
        broadcastBuffer = [[BTXBroadcastBuffer alloc] initWithChunkSize:_chunkSize];
    }
    
    [broadcastBuffer enqueueData:data];
    [self.dictionary setValue:broadcastBuffer forKey:key];
}

-(NSData*) peekDataForKey:(NSString *)key {
    BTXBroadcastBuffer* broadcastBuffer = [self getBroadcastBufferForKey:key];
    if(!broadcastBuffer) return nil;
    return [broadcastBuffer peekData];
}

-(void) markDequeuedForKey:(NSString *)key {
    BTXBroadcastBuffer* broadcastBuffer = [self.dictionary valueForKey:key];
    if(!broadcastBuffer) return;
    
    [broadcastBuffer seek];
}

-(void) removeBufferForKey:(NSString *)key {
    [self.dictionary removeObjectForKey:key];
}

-(BTXBroadcastBuffer*) getBroadcastBufferForKey: (NSString*) key {
    BTXBroadcastBuffer* broadcastBuffer = [self.dictionary valueForKey:key];
    
    // If the buffer exists, but the hasQueuedData flag is false,
    // remove the buffer from the dictionary.
    if(broadcastBuffer && !broadcastBuffer.hasQueuedData) {
        [self removeBufferForKey:key];
        return nil;
    }
    
    return broadcastBuffer;
}

@end
