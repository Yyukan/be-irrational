//
//  AnimationUtils.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 07/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import "AnimationUtils.h"

@implementation AnimationUtils

+ (void)animationTransition:(UIView *)containerView 
                previosView:(UIView *)previosView 
                   nextView:(UIView *)nextView
             withTransition:(UIViewAnimationTransition)transition
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationTransition: transition forView:containerView cache:NO];
	[previosView removeFromSuperview];
	[containerView addSubview:nextView];
	[UIView commitAnimations];
}

@end
