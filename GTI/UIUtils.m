//
//  UIUtils.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Logger.h"
#import "ImageUtils.h"
#import "UIUtils.h"

@implementation UIUtils

+ (void)setBackgroundImage:(UIView *)view image:(NSString *)image;
{
	UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:image]];
    view.backgroundColor = background;
    
    if ([view isKindOfClass:[UITableView class]])
    {
        UITableView *tableView = (UITableView *)view;
        tableView.backgroundView = nil;
    }
    [background release];
}

+ (void)setBackgroundColor:(UIView *)view
{
    view.backgroundColor = [UIColor colorWithRed:0.410 green:0.280 blue:0.170 alpha:1];
}

+ (void)setSeparatorColor:(UITableView *)tableView;
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

+ (UIColor *)tintColor
{
    return [UIColor colorWithRed:227.0/255 green:199.0/255 blue:112.0/255 alpha:1];
}

+ (UIColor *)cellBackGround
{
    return [UIColor colorWithRed:0.980 green:0.913 blue:0.710 alpha:1];
}

+ (BOOL)textView:(UITextView *)view setPlaceholder:(NSString *)placeholder
{
    if (view.text.length == 0)
    {
        [view setText:placeholder];
        [view setTextColor:[UIColor lightGrayColor]];
        return YES;
    }
    return NO;
}

+ (void)textViewRemovePlaceHolder:(UITextView *)view;
{
    view.text = @"";
    view.textColor = [UIColor blackColor];
}

+ (UIFont *)fontForDomainCell
{
    return [UIFont fontWithName:@"System" size:14.0];
}

+ (UIFont *)fontForDateCell
{
    return [UIFont systemFontOfSize:12.0f];
}

+ (UIFont *)fontForFlexibleCell
{
    return [UIFont systemFontOfSize:16.0f];
}    

+ (void)setNavigationBarImage:(UINavigationBar *)navigationBar
{
    if ([navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
    {
        [navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    }
    if ([navigationBar respondsToSelector:@selector(shadowImage)])
    {
        [navigationBar setShadowImage:[[[UIImage alloc] init] autorelease]];
    }
}

+ (void)setTabBarImage:(UITabBar *)tabBar
{
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
    {
        [tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar"]];
    }    
}

+ (void)setNavigationBarTintColor:(UINavigationBar *)navigationBar
{
    [navigationBar setTintColor:[UIUtils tintColor]];
}

@end

@implementation UINavigationBar (BackgroundImage)

- (void)drawRect:(CGRect)rect 
{
    UIImage *image = [UIImage imageNamed: @"navbar"];
    [image drawInRect:rect];
}

@end

@implementation UITabBar (BackgroundImage)

- (void)drawRect:(CGRect)rect 
{
    UIImage *image = [UIImage imageNamed: @"tabbar.png"];
    [image drawInRect:rect];
}
@end
