//
//  SomedaySwipeCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 17/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import "SomedaySwipeCell.h"

@implementation SomedaySwipeCell

@synthesize nowButton = _nowButton;
@synthesize completedButton = _completedButton;
@synthesize trashButton = _trashButton;

- (void)dealloc
{
    [_nowButton release];
    [_completedButton release];
    [_trashButton release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
