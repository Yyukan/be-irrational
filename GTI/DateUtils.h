//
//  DateUtils.h
//  WorkingHours
//
//  Created by Oleksandr Shtykhno on 16/08/2011.
//  Copyright 2011 shtykhno.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSDate *)dateWithHours:(int)hours andMinutes:(int) minutes;
+ (NSString *)formatTimeTo24Hours:(NSDate *)date;
+ (NSString *)formatDateTo24Hours:(NSDate *)date;
+ (NSString *)format:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
+ (BOOL)currentTimeAfter:(NSDate *)start andBefore:(NSDate *)end;
+ (NSString *)currentDateForTitle;
+ (BOOL)currentWeekDay:(NSNumber*)mon :(NSNumber*)tue :(NSNumber*)wed :(NSNumber*)thu :(NSNumber*)fri :(NSNumber*)sat :(NSNumber*)sun;
+ (NSString *)periodAsString:(NSDate *)start :(NSDate *)end;
+ (int)differenceInDaysFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end
