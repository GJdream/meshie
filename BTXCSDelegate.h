//
//  BTXCSDelegate.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/10/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTXPayload.h"
@class BTXNode;

@protocol BTXCSDelegate <NSObject>

-(void) onConnectionEstablishedWithNode: (BTXNode*) node;
-(void) onPayloadReceived: (BTXPayload*) payload;

@end
