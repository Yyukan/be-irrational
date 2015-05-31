//
//  Occupation.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 10/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "Occupation.h"

@implementation Occupation

@dynamic text;
@dynamic note;
@dynamic date;
@dynamic progress;
@dynamic status;
@dynamic domain;
@dynamic order;
@dynamic completedDate;

- (int)completedDays
{
    if (self.completedDate != nil)
    {
        return [DateUtils differenceInDaysFrom:self.date to:self.completedDate];
    }
    
    return [DateUtils differenceInDaysFrom:self.date to:[[Date instance] now]];
}

@end
