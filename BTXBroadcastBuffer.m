//
//  BTXBroadcast.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/4/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXBroadcastBuffer.h"

@interface BTXBroadcastBuffer()

// Array of NSData objects
@property NSMutableArray* queuedData;
@property NSInteger currentOffset; // Offset in the current NSData object in the queue array
@property NSInteger chunkSize;

@end

@implementation BTXBroadcastBuffer

+(NSData*) getTerminatingPatternForSize:(NSInteger) size {
    NSMutableData* data = [[NSMutableData alloc] init];
    unsigned char zeroByte = 255;
    
    for(int i = 0; i < size; i++)
        [data appendBytes:&zeroByte length:1];
    return data;
}

-(instancetype) initWithChunkSize:(NSInteger) size {
    self = [super init];
    if(self) {
        self.hasQueuedData = false;
        self.queuedData = [[NSMutableArray alloc] init];
        
        self.terminatingPattern = [BTXBroadcastBuffer getTerminatingPatternForSize:size];
        self.chunkSize = size;
    }
    
    return self;
}

// Data is null-terminated.
-(void) enqueueData:(NSData *)data {
    
    // Data is delimited with the terminating pattern
    [self.queuedData addObject:data];
    [self.queuedData addObject:self.terminatingPattern];
    
    self.hasQueuedData = true;
}

// Returns up to the top N bytes in the current element in the array.
-(NSData*) peekData {
    NSInteger available = [self getAvailableCount];
    NSInteger take = self.chunkSize < available ? self.chunkSize : available;
    
    if(!self.hasQueuedData || take == 0) return nil;
    
    NSData* currentItem = self.queuedData[0];
    NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[currentItem bytes] + self.currentOffset
                                         length:take
                                   freeWhenDone:NO];
    return chunk;
}

// Advances the buffer pointer
-(void) seek {
    if(!self.hasQueuedData) return;
    
    NSInteger available = [self getAvailableCount];
    
    // If we are dequeueing bytes at the end of an element in buffer
    // remove it from the queue.
    if(self.chunkSize >= available) {
        [self.queuedData removeObjectAtIndex:0];
        self.currentOffset = 0;
    } else {
        self.currentOffset += self.chunkSize; // Otherwise, increment the internal counter.
    }
    
    self.hasQueuedData = self.queuedData.count;
}

// Get the amount of data left in the current array item.
-(NSInteger) getAvailableCount {
    if([self.queuedData count] == 0) {
        return 0;
    }
    
    NSData* currentItem = self.queuedData[0];
    return currentItem.length - self.currentOffset;
}

@end
