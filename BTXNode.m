//
//  BTXNode.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXNode.h"
#import "BTXAppDelegate.h"

@interface BTXNode()

@property (nonatomic) BOOL isConnected;

@end

@implementation BTXNode

-(void) setIsConnected:(BOOL)isConnected {
    self.isConnected = isConnected;
}

-(BOOL) isConnected {
    return self.isConnected;
}

+(BTXNode*) getSelf {
    return [(BTXAppDelegate *)[[UIApplication sharedApplication] delegate] profile];
}

@end
