//
//  BTXManager.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXPCDelegate.h"
#import "BTXShared.h"

@interface BTXCentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, weak) id <BTXPCDelegate> delegate;

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray* discoveredPeripherals;

-(instancetype) initWithServiceUUID:(NSString *)serviceUUID
         characteristicUUID:(NSString *)characteristicUUID;


-(void) broadcastData: (NSData*) data;



@end
