//
//  BTXChannel.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/2/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTXClientServer.h"
#import "BTXNode.h"
#import "BTXPayload.h"

#import "BTXMeshDelegate.h"

/*
 
 A mesh is the boundary in which users communicate.
 
 * One or more users can be a part of a mesh.
 * Users can be a part of multiple meshes
 * Any users that are a part of the mesh can read and leave messages on it
    while they are connected to it.
 
 */
@interface BTXMeshClient : NSObject

@property (nonatomic, weak) id <BTXMeshDelegate> delegate;

// unique identifier that identifies this channel.
// Multiple channels can have potential naming conflicts
@property (strong, nonatomic) NSString* identifier;

// The display name for a channel
@property (strong, nonatomic) NSString* tag;

// NSArray of BTXPeer objects that represent the known peers.
@property (strong, nonatomic) NSMutableArray* peers;

// If the peer is connected as a peripheral, retain the object right here.
@property (strong, nonatomic) BTXClientServer* btxClientServer;


-(void) sendDataForChannel:(NSString *)channel data:(NSData *)data;

+(BTXMeshClient*) instance;

@end
