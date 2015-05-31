//
//  PredefinedScopeViewController.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 19/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import "BaseTabViewController.h"

@interface PredefinedScopeViewController : BaseTabViewController
{
    @private
    NSArray *_predefinedScopes;
    NSArray *_domains;
}

- (id)initWithDomains:(NSArray *)domains;

@end

@interface PredefinedScope : NSObject
{
    NSString *_title;
    NSString *_note;
    BOOL _checked;
}
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *note;

- (id)initWithTitle:(NSString *)title andNote:(NSString *)note;

@end
