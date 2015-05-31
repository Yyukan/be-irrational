//
//  TrashViewController.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BaseTabViewController.h"
#import "TrashSwipeCell.h"

@interface TrashViewController : BaseTabViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, assign) IBOutlet TrashSwipeCell *swipeCell;

@end
