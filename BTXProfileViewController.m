//
//  BTXProfileViewController.m
//  BlueTeeth
//
//  Created by Youssef Boukenken on 8/20/14.
//  Copyright (c) 2014 sefbkn. All rights reserved.
//

#import "BTXNode.h"
#import "BTXAppDelegate.h"
#import "BTXProfileViewController.h"

@interface BTXProfileViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *moodTextField;
@property (strong, nonatomic) IBOutlet UITextView *aboutTextField;

@property (strong, nonatomic) UIBarButtonItem* saveButton;

@end

@implementation BTXProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)onNameChanged:(id)sender {

}

-(void) viewWillAppear:(BOOL)animated {
    self.tabBarController.navigationItem.rightBarButtonItem = _saveButton;
    BTXNode* selfNode = [BTXNode getSelf];

    self.nameTextField.text = selfNode.displayName;
    self.moodTextField.text = selfNode.mood;
    self.aboutTextField.text = selfNode.about;
}

-(void) viewWillDisappear:(BOOL)animated {
    self.tabBarController.navigationItem.rightBarButtonItem = nil;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Build out save button
    _saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSavePressed:)];
}

-(void) onSavePressed: (UIButton*) button {
    NSArray* textFields = @[self.nameTextField, self.moodTextField, self.aboutTextField];
    for(UIView* v in textFields) {
        [v resignFirstResponder];
    }
    
    BTXNode* selfNode = [BTXNode getSelf];
    selfNode.displayName = self.nameTextField.text;
    selfNode.mood = self.moodTextField.text;
    selfNode.about = self.aboutTextField.text;
    
    BTXAppDelegate* appDelegate = (BTXAppDelegate *)[[UIApplication sharedApplication] delegate];
    BTXMeshClient* mesh = appDelegate.mesh;
    
    [mesh broadcastOwnProfile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
