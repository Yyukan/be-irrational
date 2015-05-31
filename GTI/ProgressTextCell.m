//
//  ProgressTextCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 16/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "COmmon.h"
#import "ProgressTextCell.h"

@implementation ProgressTextCell

@synthesize icon = _icon;
@synthesize label = _label;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSMutableArray *imageCache = [[NSMutableArray alloc] init];
        NSMutableArray *keyCache = [[NSMutableArray alloc] init];
        
        for (int i=0; i <= 100; i+=5)
        {
            NSString *key = [NSString stringWithFormat:@"preload%i", (i / 5) * 5];
            UIImage *image = [UIImage imageNamed:key];

            [imageCache addObject:image];
            [keyCache addObject:key];
        }
        
        _progressIcons = [[NSDictionary alloc] initWithObjects:imageCache forKeys:keyCache];
        
        [imageCache release];
        [keyCache release];
    }
    return self;    
}

- (void)dealloc
{
    [_progressIcons release];
    [_icon release];
    [_label release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)updateLabel:(NSString *)text
{
    [self.label setText:text];
}

- (void)updateIconLabelInNumber:(int)value;
{
    [self.icon setTitle:[NSString stringWithFormat:@"%i", value] forState:UIControlStateNormal];
    [self.icon setTitle:[NSString stringWithFormat:@"%i", value] forState:UIControlStateSelected];
    [self.icon setTitle:[NSString stringWithFormat:@"%i", value] forState:UIControlStateHighlighted];
}

- (void)updateIconLabelInPercent:(int)value;
{
    [self.icon setTitle:[NSString stringWithFormat:@"%3i%%", value] forState:UIControlStateNormal];
    [self.icon setTitle:[NSString stringWithFormat:@"%3i%%", value] forState:UIControlStateSelected];
    [self.icon setTitle:[NSString stringWithFormat:@"%3i%%", value] forState:UIControlStateHighlighted];
}

- (void)updateIconImage:(int)value
{
    NSString *imageName = (value > 100) ? @"preload100" : [NSString stringWithFormat:@"preload%i", (value / 5) * 5] ;
    
    [self.icon setBackgroundImage:[_progressIcons objectForKey:imageName] forState:UIControlStateNormal];
}

@end
