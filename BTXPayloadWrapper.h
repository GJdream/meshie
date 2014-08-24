//
//  BTXPayloadWrapper.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/24/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXPayload.h"
#import <Foundation/Foundation.h>

@interface BTXPayloadWrapper : NSObject

@property NSString* peripheralUUID;
@property NSString* centralUUID;

@property BTXPayload* payload;

@end
