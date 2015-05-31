//
//  CompletedSwipeCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 17/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import "CompletedSwipeCell.h"

@implementation CompletedSwipeCell

@synthesize nowButton = _nowButton;
@synthesize trashButton = _trashButton;
@synthesize somedayButton = _somedayButton;

- (void)dealloc
{
    [_nowButton release];
    [_trashButton release];
    [_somedayButton release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
