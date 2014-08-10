//
//  BTXCSDelegate.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/10/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTXPayload.h"

@protocol BTXCSDelegate <NSObject>

-(void) onPayloadReceived: (BTXPayload*) payload;

@end
