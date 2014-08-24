//
//  BTXPeerTableViewCell.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/23/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXPeerTableViewCell.h"

@interface BTXPeerTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *peerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *peerMoodLabel;
@property (strong, nonatomic) IBOutlet UILabel *peerAboutLabel;

@end

@implementation BTXPeerTableViewCell

@synthesize node = _node;

-(BTXNode*) node {
    return _node;
}

-(void)setNode:(BTXNode *)node {
    _node = node;
    
    [self updateLabels];
}

-(void) updateLabels {
    if (!self.node) {
        return;
    }
    
    self.peerNameLabel.text = self.node.displayName;
    self.peerMoodLabel.text = self.node.mood;
    self.peerAboutLabel.text = self.node.about;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
