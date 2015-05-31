//
//  ScopeSwipeCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 12/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import "ScopeSwipeCell.h"

@implementation ScopeSwipeCell

@synthesize editButton = _editButton;
@synthesize completeButton = _completeButton;
@synthesize somedayButton = _somedayButton;
@synthesize trashButton = _trashButton;

#pragma mark - Initialization

- (void)dealloc
{
    [_editButton release];
    [_completeButton release];
    [_somedayButton release];
    [_trashButton release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
