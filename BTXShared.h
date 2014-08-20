//
//  BTXUUID.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTXPayloadType.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

@interface BTXShared : NSObject

#define MSH_SERVICE_UUID                    @"713d0000-503e-4c75-ba94-3148f18d941e"
#define MSH_TX_UUID                         @"713d0003-503e-4c75-ba94-3148f18d941e"

@end