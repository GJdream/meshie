//
//  BTXAppDelegate.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTXClientServer.h"
#import "BTXMesh.h"


@interface BTXAppDelegate : UIResponder <UIApplicationDelegate>

@property BTXNode* profile;
@property BTXMesh* mesh;

@property (strong, nonatomic) UIWindow *window;

@end
