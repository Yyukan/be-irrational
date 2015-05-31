//
//  AnimationUtils.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 07/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationUtils : NSObject

+ (void)animationTransition:(UIView *)containerView 
                previosView:(UIView *)previosView 
                   nextView:(UIView *)nextView
             withTransition:(UIViewAnimationTransition)transition;

@end
