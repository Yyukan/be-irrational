//
//  Domain.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 08/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Logger.h"
#import "Domain.h"


@implementation Domain

@dynamic text;
@dynamic note;
@dynamic date;
@dynamic order;
@dynamic occupations;
@dynamic status;

- (BOOL)hasOccupations
{
    return (self.occupations != nil && self.occupations.count > 0);
}

- (BOOL)hasOccupationsInStatusNormal
{
    if ([self hasOccupations])
    {
        for (Occupation *occupation in self.occupations)
        {
            if (occupation.status.intValue == STATUS_OCCUPATION_NORMAL.intValue)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (int)numberOfOccupations
{
    int result = 0;
    if ([self hasOccupations])
    {
        for (Occupation *occupation in self.occupations)
        {
            if (occupation.status.intValue == STATUS_OCCUPATION_NORMAL.intValue)
            {
                result ++;
            }    
        }
        
    }
    return result;
}


@end
