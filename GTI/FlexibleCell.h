//
//  FlexibleCell.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 21/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlexibleCell : UITableViewCell
{
    UIImageView *_iconView;
    UILabel *_textView;
}
@property (nonatomic, retain) IBOutlet UIImageView *iconView;
@property (nonatomic, retain) IBOutlet UILabel *textView;

- (CGFloat)heightForCell;

@end
