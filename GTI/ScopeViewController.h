//
//  ScopeViewController.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabViewController.h"
#import "TitleNoteViewController.h"
#import "ProgressTextCell.h"
#import "ScopeSwipeCell.h"

@interface ScopeViewController : BaseTabViewController <TitleNoteViewControllerDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
{
    @private
    BOOL _reordering;
}

@property (nonatomic, assign) IBOutlet ScopeSwipeCell *scopeSwipeCell;
@property (nonatomic, assign) IBOutlet ProgressTextCell *progressTextCell;

@end
