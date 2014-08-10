//
//  BTXClientServer.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTXPeripheralManager.h"
#import "BTXCentralManager.h"
#import "BTXPayload.h"

@interface BTXClientServer : NSObject {
    BTXPeripheralManager* btxPeripheralManager;
    BTXCentralManager* btxCentralManager;
}

@property NSArray* messageCache;

-(void) broadcastPayload: (BTXPayload*) payload;

@end
