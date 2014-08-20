//
//  BTXMeshDelegate.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/19/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BTXMeshDelegate <NSObject>

-(void) onMessageReceived:(NSString*) message;

@end
