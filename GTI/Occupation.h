//
//  Occupation.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 10/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Domain.h" 

#define STATUS_OCCUPATION_NORMAL   [NSNumber numberWithInt:0]
#define STATUS_OCCUPATION_TRASH    [NSNumber numberWithInt:1]
#define STATUS_OCCUPATION_SOMEDAY  [NSNumber numberWithInt:2]
#define STATUS_OCCUPATION_COMPLETED    [NSNumber numberWithInt:3]

@class Domain;

@interface Occupation : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) Domain * domain;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * completedDate;

- (int)completedDays;

@end
