//
//  ProgressTextCell.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 16/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressTextCell : UITableViewCell
{
    NSDictionary *_progressIcons;
}

@property (nonatomic, retain) IBOutlet UIButton *icon;
@property (nonatomic, retain) IBOutlet UILabel *label;

- (void)updateIconLabelInNumber:(int)value;
- (void)updateIconLabelInPercent:(int)value;
- (void)updateIconImage:(int)value;
- (void)updateLabel:(NSString *)text;

@end
