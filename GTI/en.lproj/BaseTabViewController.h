//
//  BaseTabViewController.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Domain.h"
#import <CoreData/CoreData.h>

@interface BaseTabViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSIndexPath *_swipedIndexPath;
    
    UITableView *_tableView;
    UIImageView *_notepadHeader;
    UIImageView *_notepadFooter;
    
    UIImage *_notepadHeaderPortrait;
    UIImage *_notepadHeaderLandscape;
    
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, retain) NSIndexPath *swipedIndexPath;
@property (nonatomic, retain) UIImage *notepadHeaderPortrait;
@property (nonatomic, retain) UIImage *notepadHeaderLandscape;

@property (nonatomic, retain) IBOutlet UITableView *tableView;    
@property (nonatomic, retain) IBOutlet UIImageView *notepadHeader;
@property (nonatomic, retain) IBOutlet UIImageView *notepadFooter;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)fetchedResultControllerInitialLoad;
- (BOOL)cellIsSwiped:(NSIndexPath *)indexPath;
- (void)updateOrder:(NSArray *)domains;
- (NSNumber *)numberOfOccupationsWithDomain:(Domain *)domain andStatus:(NSNumber *)status;
- (void)updateOccupationOrderForDomain:(Domain *)domain withStatus:(NSNumber *)status;

@end
