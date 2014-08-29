//
//  BTXNode.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface BTXNode : JSONModel <NSCoding>

@property (strong, nonatomic) NSString* identifier;
@property (strong, nonatomic) NSString* displayName;

@property (strong, nonatomic) NSString* centralUUID;
@property (strong, nonatomic) NSString* peripheralUUID;

@property (strong, nonatomic) NSString* mood;
@property (strong, nonatomic) NSString* about;

@property (strong, nonatomic) NSDate* lastSeenOn;

@property BOOL isConnected;

+(BTXNode*) getSelf;

@end
