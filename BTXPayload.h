//
//  BTXDataPacket.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "JSONModel.h"
#import <Foundation/Foundation.h>

@interface BTXPayload : JSONModel


// The type of packet received.
// Certain packets are not propogated through network
// Certain types are...
@property NSInteger type;
@property (strong, nonatomic) NSString* uid;

@property (strong, nonatomic) NSString* peerid; // peer id
@property (strong, nonatomic) NSString* mesh; // mesh name / channel
@property (strong, nonatomic) NSDate* ts; // timestamp w/ timezone.
@property (strong, nonatomic) NSString* data; // data.... text message maybe

@end
