//
//  UIUtils.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <Foundation/Foundation.h>

///////////////////////////////////////
// Global user interface constants 
//
#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)

#define GLOBAL_CELL_SELECTION_STYLE UITableViewCellSelectionStyleBlue

@interface UIUtils : NSObject

+ (void)setBackgroundImage:(UIView *)view image:(NSString *)image;
+ (void)setBackgroundColor:(UIView *)view;

+ (void)setNavigationBarImage:(UINavigationBar *)navigationBar;
+ (void)setNavigationBarTintColor:(UINavigationBar *)navigationBar;

+ (void)setTabBarImage:(UITabBar *)tabBar;

+ (UIColor *)cellBackGround;
+ (UIColor *)tintColor;

+ (void)setSeparatorColor:(UITableView *)tableView;

+ (BOOL)textView:(UITextView *)view setPlaceholder:(NSString *)placeholder;
+ (void)textViewRemovePlaceHolder:(UITextView *)view;

+ (UIFont *)fontForDomainCell;
+ (UIFont *)fontForFlexibleCell;
+ (UIFont *)fontForDateCell;


@end
