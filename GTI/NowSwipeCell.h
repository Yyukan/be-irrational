//
//  NowSwipeCell.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 12/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NowSwipeCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *editButton;
@property (nonatomic, retain) IBOutlet UIButton *completedButton;
@property (nonatomic, retain) IBOutlet UIButton *somedayButton;
@property (nonatomic, retain) IBOutlet UIButton *trashButton;

@end
