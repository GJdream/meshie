//
//  BTXPeripheral.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BTXShared.h"
#import "BTXBroadcastBuffer.h"

@interface BTXPeripheralManager : NSObject <CBPeripheralManagerDelegate> {
}

@property (nonatomic, strong) BTXBroadcastBuffer* broadcastBuffer;
@property (nonatomic, strong) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic* transferCharacteristic;

-(instancetype) initWithServiceUUID:(NSString*) serviceUUID
                 characteristicUUID:(NSString*) characteristicUUID;

-(void) flushBroadcastBuffer;

-(void) startAdvertising;
-(void) stopAdvertising;

@end
