//
//  BTXPayloadType.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/13/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum BTXPayloadType : NSInteger {
    BTXPayloadProfileRequest,
    BTXPayloadProfileResponse,
    BTXPayloadChannelMessage
} BTXPayloadType;
