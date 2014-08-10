//
//  BTXReceiveBuffer.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/10/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTXReceiveBuffer : NSObject

-(instancetype) initWithChunkSize:(NSInteger) size;

// Accumulates data with a particular key value until the
// terminating byte pattern is reached.

// Returns true if the buffer process is complete.
-(BOOL) bufferData: (NSData*) data
            forKey: (NSString*) key;


// Returns buffered data for a particular key.
// This method removes its internal reference to the buffered data
// after being called.
-(NSData*) dataForKey: (NSString*) key;

@end
