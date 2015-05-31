//
//  Domain.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 08/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Occupation.h"

#define STATUS_DOMAIN_NORMAL   [NSNumber numberWithInt:0]
#define STATUS_DOMAIN_TRASH    [NSNumber numberWithInt:1]
#define STATUS_DOMAIN_SOMEDAY  [NSNumber numberWithInt:2]
#define STATUS_DOMAIN_COMPLETED    [NSNumber numberWithInt:3]

@class Occupation;

@interface Domain : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet *occupations;
@property (nonatomic, retain) NSNumber * status;

- (BOOL)hasOccupations;
- (BOOL)hasOccupationsInStatusNormal;
- (int)numberOfOccupations;
@end

@interface Domain (CoreDataGeneratedAccessors)
- (void)addOccupationsObject:(Occupation *)value;
- (void)removeOccupationsObject:(Occupation *)value;
- (void)addOccupations:(NSSet *)values;
- (void)removeOccupations:(NSSet *)values;
@end
