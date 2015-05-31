//
//  ProgressCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 15/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "ProgressCell.h"

@implementation ProgressCell

@synthesize progressButton = _progressButton;
@synthesize progressSlider = _progressSlider;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        TRC_ENTRY
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
    [_progressButton release];
    [_progressSlider release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)updateProgressLabel:(float)value
{
    [self.progressButton setTitle:[NSString stringWithFormat:@"%3i%%", (int)value] forState:UIControlStateNormal];
    [self.progressButton setTitle:[NSString stringWithFormat:@"%3i%%", (int)value] forState:UIControlStateSelected];
    [self.progressButton setTitle:[NSString stringWithFormat:@"%3i%%", (int)value] forState:UIControlStateHighlighted];
}

- (void)updateProgressIcon:(float)value
{
    NSString *imageName = [NSString stringWithFormat:@"preload%i", ((int)value / 5) * 5];
    
    [self.progressButton setBackgroundImage:[_progressIcons objectForKey:imageName] forState:UIControlStateNormal];
}

@end
