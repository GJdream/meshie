//
//  BTXChannelTableViewController.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/20/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXMeshClient.h"
#import "BTXChatViewController.h"
#import "BTXChannelTableViewController.h"

#import "FontAwesomeKit/FontAwesomeKit.h"

#define PEER_CELL_ID @"PeerCell"

@interface BTXChannelTableViewController () <BTXMeshDelegate>

@end

@implementation BTXChannelTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BTXMeshClient* meshClient = [BTXMeshClient instance];
    meshClient.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onMessageReceived:(NSString *)message fromNode:(BTXNode *)node onChannel:(NSString *)channel {
    [self.tableView reloadData];
}

-(void) onPeerConnectionStateChanged {
    NSLog(@"Connection state changed.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"Channels", @"Nearby Users"][section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 1;
    }
    
    if(section == 1) {
        BTXMeshClient* meshClient = [BTXMeshClient instance];
        return [meshClient connectedPeers].count;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Style"];
        
        if(indexPath.section == 0 && indexPath.row == 0) {
            cell.textLabel.text = @"# everyone";
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    else if (indexPath.section == 1) {
        UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PEER_CELL_ID];
        
        BTXNode* node = [self getNodeByIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"@ %@", node.displayName];
        cell.detailTextLabel.text = node.mood;
        
        return cell;
    }
    
    else return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 && indexPath.section == 0) {
        // Navigate to the chat view for all channels;
        BTXChatViewController* chatViewController = [[BTXChatViewController alloc] init];
        chatViewController.channel = @"everyone";
        
        [self.navigationController pushViewController:chatViewController animated:true];
    }
    
    else if(indexPath.section == 1) {
        BTXChatViewController* chatViewController = [[BTXChatViewController alloc] init];
        BTXNode* node = [self getNodeByIndex:indexPath.row];
        chatViewController.channel = node.displayName;
        
        [self.navigationController pushViewController:chatViewController animated:true];
    }
}

-(BTXNode*) getNodeByIndex: (NSInteger) index {
    BTXMeshClient* meshClient = [BTXMeshClient instance];
    BTXNode* node = [meshClient connectedPeers][index];
    return node;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
