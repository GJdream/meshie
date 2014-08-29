//
//  BTXTabBarViewController.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/23/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXTabBarViewController.h"
#import "BTXCommon.h"
#import "FontAwesomeKit/FontAwesomeKit.h"

@interface BTXTabBarViewController ()

@end

@implementation BTXTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int s = 23;
    
    CGSize size = CGSizeMake(s, s);
    FAKFontAwesome *meshIcon = [FAKFontAwesome commentsOIconWithSize:s];
    FAKFontAwesome *profileIcon = [FAKFontAwesome cogsIconWithSize:s];
    
    NSArray* icons = @[meshIcon, profileIcon];
    
    int x = 0;
    for (UITabBarItem* item in self.tabBar.items) {
        FAKFontAwesome* icon = icons[x++];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];

        UIImage* image = [icon imageWithSize:size];

        item.image = image;
    }
    
    self.tabBar.tintColor = [BTXCommon primaryThemeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
