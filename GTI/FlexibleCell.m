//
//  FlexibleCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 21/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "FlexibleCell.h"

#define DEFAULT_CELL_HEIGHT 44.0
#define DEFAULT_CELL_MARGIN 20.0

@implementation FlexibleCell

@synthesize iconView = _iconView;
@synthesize textView = _textView;

- (void)dealloc
{
    [_iconView release];
    [_textView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (CGSize)defineConstraintSize
{
    if ([Utils isDeviceAniPad])
    {
        if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        {
            return CGSizeMake(708.0f, MAXFLOAT);
        } 
        else 
        {
            return CGSizeMake(970.0f, MAXFLOAT);
        }
    }    
    else 
    {
        if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        {
            return CGSizeMake(266.0f, MAXFLOAT);
        } 
        else 
        {
            return CGSizeMake(426.0f, MAXFLOAT);
        }
    }
}

- (CGFloat)heightForCell
{
    CGSize constraintSize = [self defineConstraintSize];
    
    CGSize size = [self.textView.text sizeWithFont:self.textView.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    TRC_DBG(@"Cell label size width [%f] height [%f] lines [%f] font %f", size.width, size.height, size.height/self.textView.font.pointSize, self.textView.font.pointSize);
    return MAX(DEFAULT_CELL_HEIGHT, size.height + DEFAULT_CELL_MARGIN);
}

@end
