//
//  NoteViewController.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 06/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Occupation.h"
#import "ProgressCell.h"
#import "ProgressTextCell.h"
#import "FlexibleCell.h"
#import "TitleNoteViewController.h"

@interface NoteViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TitleNoteViewControllerDelegate>
{
    @private
    int _index;
    BOOL _showEditButton;
    BOOL _showTrashButton;
    BOOL _showProgress;
}

@property (nonatomic, assign, getter=isShowEditButton) BOOL showEditButton;
@property (nonatomic, assign, getter=isShowTrashButton) BOOL showTrashButton;
@property (nonatomic, assign, getter=isShowProgress) BOOL showProgress;

@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *trashButton;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *notepadHeader;
@property (nonatomic, retain) IBOutlet UIImageView *notepadFooter;

@property (nonatomic, retain) FlexibleCell *titleCell;
@property (nonatomic, retain) FlexibleCell *noteCell;

@property (nonatomic, retain) IBOutlet ProgressCell *progressCell;
@property (nonatomic, retain) IBOutlet ProgressTextCell *progressTextCell;

@property (nonatomic, assign) IBOutlet FlexibleCell *flexibleCell;

@property (nonatomic, assign) Occupation *occupation;
@property (nonatomic, retain) NSMutableArray *occupations;

- (id)initWithOccupation:(Occupation *)occupation andOccupations:(NSMutableArray *)occupations andIndex:(int)index;

@end
