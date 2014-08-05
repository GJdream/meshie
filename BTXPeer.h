//
//  BTXPeer.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTXPeer : NSObject

@property (strong, nonatomic) NSString* identifier;

// Returns whether or not the peer is within range
-(BOOL) isInRange;

@end
