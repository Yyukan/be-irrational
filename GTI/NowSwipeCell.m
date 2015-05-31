//
//  NowSwipeCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 12/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import "NowSwipeCell.h"

@implementation NowSwipeCell

@synthesize editButton = _editButton;
@synthesize completedButton = _completedButton;
@synthesize somedayButton = _somedayButton;
@synthesize trashButton = _trashButton;

#pragma mark - Initialization

- (void)dealloc
{
    [_editButton release];
    [_completedButton release];
    [_somedayButton release];
    [_trashButton release];
    [super dealloc];
}

#pragma mark - View lifecycle 

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
