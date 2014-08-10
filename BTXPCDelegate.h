//
//  BTXPCDelegate.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/10/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXShared.h"
#import <Foundation/Foundation.h>

@protocol BTXPCDelegate <NSObject>   //define delegate protocol


-(void) onDataReceived:(NSData*) data
        fromPeripheral: (CBPeripheral*) peripehral;

// Returns data sent from the central to the current peripehral.
-(void) onDataReceived: (NSData*) data
           fromCentral: (CBCentral*) central;

@end //end protocol
