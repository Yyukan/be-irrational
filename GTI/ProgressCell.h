//
//  ProgressCell.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 15/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressCell : UITableViewCell
{
    NSDictionary *_progressIcons;
}

@property (nonatomic, retain) IBOutlet UIButton *progressButton;
@property (nonatomic, retain) IBOutlet UISlider *progressSlider;

- (void)updateProgressLabel:(float)value;
- (void)updateProgressIcon:(float)value;

@end
