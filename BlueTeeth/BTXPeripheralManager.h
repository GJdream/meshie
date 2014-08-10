//
//  BTXPeripheral.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BTXPCDelegate.h"
#import "BTXShared.h"

@interface BTXPeripheralManager : NSObject <CBPeripheralManagerDelegate> {
}

@property (nonatomic, weak) id <BTXPCDelegate> delegate;


@property (nonatomic, strong) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic* transferCharacteristic;

-(instancetype) initWithServiceUUID:(NSString*) serviceUUID
                 characteristicUUID:(NSString*) characteristicUUID;

-(void) broadcastData: (NSData*) data;

-(void) startAdvertising;
-(void) stopAdvertising;

@end
