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

@end

@implementation BTXNode

+(BTXNode*) getSelf {
    return [(BTXAppDelegate *)[[UIApplication sharedApplication] delegate] profile];
}

+(BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.identifier = [decoder decodeObjectForKey:@"identifier"];
    self.displayName = [decoder decodeObjectForKey:@"displayName"];
    
    self.centralUUID = [decoder decodeObjectForKey:@"centralUUID"];
    self.peripheralUUID = [decoder decodeObjectForKey:@"peripheralUUID"];
    
    self.mood = [decoder decodeObjectForKey:@"mood"];
    self.about = [decoder decodeObjectForKey:@"about"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeObject:self.identifier forKey:@"displayName"];
    
    [encoder encodeObject:self.identifier forKey:@"centralUUID"];
    [encoder encodeObject:self.identifier forKey:@"peripheralUUID"];
    
    [encoder encodeObject:self.identifier forKey:@"mood"];
    [encoder encodeObject:self.identifier forKey:@"about"];
}

@end
