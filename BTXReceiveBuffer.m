//
//  BTXReceiveBuffer.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/10/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXBroadcastBuffer.h"
#import "BTXReceiveBuffer.h"

@interface BTXReceiveBuffer()

@property NSInteger chunkSize;
@property NSMutableDictionary* dictionary;
@property NSData* terminatingPattern;

@end

@implementation BTXReceiveBuffer

-(instancetype) init {
    return [self initWithChunkSize:20];
}

-(instancetype) initWithChunkSize:(NSInteger) size {
    self = [super init];
    if(self) {
        self.dictionary = [[NSMutableDictionary alloc] init];
        self.terminatingPattern = [BTXBroadcastBuffer getTerminatingPatternForSize:size];
        self.chunkSize = size;
    }
    
    return self;
}


-(BOOL) bufferData:(NSData *)data forKey:(NSString *)key {
    // If terminating pattern detected, return true
    // which indicates that buffering is completed.
    if([data isEqualToData:self.terminatingPattern])
        return true;
    
    NSMutableData* bufferedData = [self.dictionary valueForKey:key];
    if(!bufferedData) {
        // If no data for this key, create buffer
        bufferedData = [[NSMutableData alloc] initWithData:data];
    } else {
        // Otherwise, append data to existing buffer
        [bufferedData appendData:data];
    }
    
    [self.dictionary setValue:bufferedData forKey:key];
    return false;
}

-(NSData*) dataForKey:(NSString *)key {
    NSData* data = [self.dictionary valueForKey:key];
    
    [self.dictionary removeObjectForKey:key];
    
    return data;

}

@end
