//
//  NowViewController.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabViewController.h"
#import "TitleNoteViewController.h"
#import "Domain.h"
#import "NowSwipeCell.h"
#import "ProgressTextCell.h"

@interface NowViewController : BaseTabViewController <TitleNoteViewControllerDelegate, NSFetchedResultsControllerDelegate>
{
    @private
    BOOL _reordering;
}

@property (nonatomic, assign) IBOutlet NowSwipeCell *nowSwipeCell;
@property (nonatomic, assign) IBOutlet ProgressTextCell *progressTextCell;

@property (nonatomic, assign) Domain *domain;

- (id)initWithDomain:(Domain *)domain;

@end
