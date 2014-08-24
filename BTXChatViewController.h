//
//  BTXChatViewController.h
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/15/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>

@interface BTXChatViewController : JSQMessagesViewController

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString* channel;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@end
