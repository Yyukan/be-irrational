//
//  TrashSwipeCell.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 17/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import "TrashSwipeCell.h"

@implementation TrashSwipeCell

@synthesize nowButton = _nowButton;
@synthesize completedButton = _completedButton;
@synthesize somedayButton = _somedayButton;

- (void)dealloc
{
    [_nowButton release];
    [_completedButton release];
    [_somedayButton release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
