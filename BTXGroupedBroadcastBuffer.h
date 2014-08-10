//
//  BTXGroupedBroadcastBuffer.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/5/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTXGroupedBroadcastBuffer : NSObject

@property NSDate* createdOn;

-(instancetype) initWithChunkSize: (NSInteger) chunkSize;

-(void) enqueueData: (NSData*) data
             forKey: (NSString*) key;

-(NSData*) peekDataForKey: (NSString*) key;

-(void) markDequeuedForKey: (NSString*) key;

-(BOOL) hasDataForKey: (NSString*) key;

-(void) removeBufferForKey: (NSString*) key;

@end
