//
//  DateGateway.h
//  WorkingHours
//
//  Created by Oleksandr Shtykhno on 21/08/2011.
//  Copyright 2011 shtykhno.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DateProtocol <NSObject>

- (NSDate *)now;

@end

@interface Date : NSObject <DateProtocol>
{
    @private
    id<DateProtocol> _date;
}
@property (nonatomic, retain) id<DateProtocol> date;

+ (Date *)instance;

@end
