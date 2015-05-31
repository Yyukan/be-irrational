//
//  DateUtils.m
//  WorkingHours
//
//  Created by Oleksandr Shtykhno on 16/08/2011.
//  Copyright 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"

#import "DateUtils.h"
#import "Date.h"

#define SECONDS_IN_DAY 86400

@implementation DateUtils

+(NSDate *) dateWithHours:(int) hours andMinutes:(int) minutes
{
    
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    components.year = 2000;
    components.month = 1;
    components.day = 1;
    components.hour = hours;
    components.minute = minutes;
    components.second = 0;
    
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];

    return [calendar dateFromComponents:components];
}

+(NSString *) formatTimeTo24Hours:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setLocale: [NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [dateFormatter stringFromDate:date];
}

+(NSString *) formatDateTo24Hours:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setLocale: [NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [dateFormatter stringFromDate:date];
}

+(NSString *) format:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setLocale: [NSLocale currentLocale]];
    [dateFormatter setDateStyle:dateStyle];
    [dateFormatter setTimeStyle:timeStyle];
    
    return [dateFormatter stringFromDate:date];
}

/**
 * Returns yes if current time between start time and end time
 */
+(BOOL) currentTimeAfter:(NSDate *)start andBefore:(NSDate *)end
{
    NSDate *now = [[Date instance] now];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];

    NSDateComponents* componentsNow = [calendar components: NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
    NSDateComponents* componentsStart = [calendar components: NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:start];
    NSDateComponents* componentsEnd = [calendar components: NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:end];
    
    NSDate *timeNow = [calendar dateFromComponents:componentsNow];
    NSDate *timeStart = [calendar dateFromComponents:componentsStart];
    NSDate *timeEnd = [calendar dateFromComponents:componentsEnd];
    
    NSTimeInterval startEndDifference = [timeEnd timeIntervalSinceDate:timeStart];
    NSTimeInterval nowStartDifference = [timeNow timeIntervalSinceDate:timeStart];
    
    if (startEndDifference < 0) startEndDifference = SECONDS_IN_DAY - fabs(startEndDifference);
    if (nowStartDifference < 0) nowStartDifference = SECONDS_IN_DAY - fabs(nowStartDifference);
    
    return (startEndDifference - nowStartDifference >= 0);
}

/**
 * Returns current date as string like this "Sat 20 Aug"
 */
+ (NSString *)currentDateForTitle
{
    NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [outputFormatter setDateFormat:@"EEE dd MMM"];
    return [outputFormatter stringFromDate:[[Date instance] now]];
}

/**
 * Returns the number of weekend 1 for Sunday, 2 for Mondat etc
 */
+ (NSInteger) nowWeekday
{
    NSDate *now = [[Date instance] now];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *weekdayComponents =
        [calendar components:(NSWeekdayCalendarUnit) fromDate:now];
    
    return [weekdayComponents weekday];
}

+ (BOOL)currentWeekDay:(NSNumber*)mon :(NSNumber*)tue :(NSNumber*)wed :(NSNumber*)thu :(NSNumber*)fri :(NSNumber*)sat :(NSNumber*)sun
{
    switch([DateUtils nowWeekday])
    {
        case 2:
            return [mon boolValue];
        case 3:
            return [thu boolValue];
        case 4:
            return [wed boolValue];
        case 5:
            return [thu boolValue];
        case 6:
            return [fri boolValue];
        case 7:
            return [sat boolValue];
        case 1:
            return [sun boolValue];
        default:
            return NO;
    }    
}

+ (NSString *)periodAsString:(NSDate *)start :(NSDate *)end
{
    NSMutableString *period = [NSMutableString string];
    [period appendString:[DateUtils formatTimeTo24Hours:start]];
    [period appendString:@" - "];
    [period appendString:[DateUtils formatTimeTo24Hours:end]];
    return period;
}

+ (NSDate *) toLocalTime:(NSDate *)date
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

+ (int)differenceInDaysFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    int dayFrom = [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:[DateUtils toLocalTime:fromDate]];
    int dayTo = [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:[DateUtils toLocalTime:toDate]];
    
    return dayTo - dayFrom;
}

@end
