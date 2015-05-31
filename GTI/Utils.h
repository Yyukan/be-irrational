//
//  Utils.h
//  WorkingHours
//
//  Created by Oleksandr Shtykhno on 27/08/2011.
//  Copyright 2011 shtykhno.net. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define ACTION_SHEET_DELETE_SCOPE_TAG 1001
#define ACTION_SHEET_EMPTY_TRASH_TAG 1002
#define ACTION_SHEET_TRASH_OCCUPATION_TAG 1003
#define ACTION_SHEET_MOVE_OCCUPATION_SOMEDAY_TAG 1004
#define ACTION_SHEET_MOVE_OCCUPATION_COMPLETED_TAG 1005

@interface Utils : NSObject

+ (void)tableViewController:(UITableViewController*) controller presentModal:(UITableViewController *)modal;
+ (void)showRequiredNameAlert;

+ (void)showDeleteCancelAction:(UIView*)view deleteCaption:(NSString *)deleteCaption cancelCaption:(NSString *) cancelCaption delegate:(id<UIActionSheetDelegate>)delegate tag:(int)tag;

+ (void)showEmptyTrashAction:(UIView*)view delegate:(id<UIActionSheetDelegate>)delegate;

+ (UIView *)emptyView;
//
// Functions to work with tables
//
+ (UITableViewCell *)tableView:(UITableView *)tableView cellInsert:(NSIndexPath *)indexPath identifier:(NSString *)identifier text:(NSString *)text;

+ (UIGestureRecognizer *)gestureWithDirection:(UISwipeGestureRecognizerDirection)direction target:(id)target selector:(SEL)selector;

+ (BOOL)isDeviceAniPad;

@end

static inline BOOL isEmpty(id thing) 
{
    return thing == nil
    || [thing isKindOfClass:[NSNull class]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}