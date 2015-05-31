//
//  Utils.m
//  WorkingHours
//
//  Created by Oleksandr Shtykhno on 27/08/2011.
//  Copyright 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"

@implementation Utils

+ (void)tableViewController:(UITableViewController*) controller presentModal:(UITableViewController *)modal;
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:modal];
	navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [controller.navigationController presentModalViewController:navigationController animated:YES];
	
    [navigationController release];
}

+ (UIGestureRecognizer *)gestureWithDirection:(UISwipeGestureRecognizerDirection)direction target:(id)target selector:(SEL)selector
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:selector];
    [gesture setDirection:direction];
    return [gesture autorelease];
}

+ (void)showRequiredNameAlert 
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                    message:@"Please enter name"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Action sheets
//

+ (void)showDeleteCancelAction:(UIView*)view deleteCaption:(NSString *)deleteCaption cancelCaption:(NSString *) cancelCaption delegate:(id<UIActionSheetDelegate>)delegate tag:(int)tag
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:delegate 
                                                    cancelButtonTitle:cancelCaption
                                               destructiveButtonTitle:deleteCaption 
                                                    otherButtonTitles:nil];
    [actionSheet setTag:tag];
    [actionSheet setDelegate:delegate];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
	[actionSheet showInView:view]; 
	[actionSheet release];
}

+ (void)showEmptyTrashAction:(UIView*)view delegate:(id<UIActionSheetDelegate>)delegate
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:delegate 
                                                    cancelButtonTitle:@"Cancel" 
                                               destructiveButtonTitle:@"Empty Trash" 
                                                    otherButtonTitles:nil];
    [actionSheet setTag:ACTION_SHEET_EMPTY_TRASH_TAG];
    [actionSheet setDelegate:delegate];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
	[actionSheet showInView:view]; 
	[actionSheet release];
}

/**
 * Creates cell for insert with identifer and simple text, identifier should be static string declared before
 */
+ (UITableViewCell *)tableView:(UITableView *)tableView cellInsert:(NSIndexPath *)indexPath identifier:(NSString *)identifier text:(NSString *)text
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = GLOBAL_CELL_SELECTION_STYLE;
    }
    [cell.textLabel setText:text];
    [cell.textLabel setFont:[UIUtils fontForDomainCell]];
    [cell setShowsReorderControl:NO];
    [cell setBackgroundColor:[UIUtils cellBackGround]];

    return cell;
}

+ (UIView *)emptyView
{
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

+ (BOOL)isDeviceAniPad 
{
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

@end
