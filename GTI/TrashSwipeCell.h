//
//  TrashSwipeCell.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 17/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrashSwipeCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *nowButton;
@property (nonatomic, retain) IBOutlet UIButton *completedButton;
@property (nonatomic, retain) IBOutlet UIButton *somedayButton;

@end
