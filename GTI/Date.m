//
//  DateGateway.m
//  WorkingHours
//
//  Created by Oleksandr Shtykhno on 21/08/2011.
//  Copyright 2011 shtykhno.net. All rights reserved.
//
#import "Logger.h"
#import "Date.h"
#import "DateGateway.h"

static Date *_instance = nil;

@implementation Date

@synthesize date = _date;

- (void)dealloc
{
    [super dealloc];
}

- (NSDate *)now
{
    return [_date now]; 
}

- (id)retain
{ 
	return self;
} 

- (NSUInteger)retainCount
{
	return NSUIntegerMax;
}

- (id)autorelease
{ 
	return self;
}

+ (Date *)instance
{
    @synchronized(self)
    {
        if (_instance == nil)
        {
            _instance = [[super alloc] init];
            _instance.date = [[[DateGateway alloc] init] autorelease];
            return _instance;
        }
    } 
    
    return _instance;
}

@end
