//
//  BTXViewController.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 7/27/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXViewController.h"
#import "BTXMeshClient.h"
#import "BTXAppDelegate.h"

@interface BTXViewController ()

@property BTXMeshClient* mesh;


@end

@implementation BTXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    BTXAppDelegate* appDelegate = (BTXAppDelegate *)[[UIApplication sharedApplication] delegate];
    _mesh = appDelegate.mesh;
}

- (IBAction)onSendPressed:(id)sender {
    NSData* data = [[self.textField text] dataUsingEncoding:NSUTF8StringEncoding];
    [self.mesh sendDataForChannel:@"#all" data:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
