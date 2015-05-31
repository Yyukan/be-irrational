//
//  BaseTabViewController.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "Domain.h"
#import "BaseTabViewController.h"
#import "PersistenceManager.h"
#import "UIUtils.h"

@implementation BaseTabViewController

@synthesize tableView = _tableView;
@synthesize notepadHeader = _notepadHeader;
@synthesize notepadFooter = _notepadFooter;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize swipedIndexPath = _swipedIndexPath;
@synthesize notepadHeaderPortrait = _notepadHeaderPortrait;
@synthesize notepadHeaderLandscape = _notepadHeaderLandscape;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        TRC_ENTRY
        self.swipedIndexPath = nil;
        
        if ([Utils isDeviceAniPad])
        {
            self.notepadHeaderPortrait = [UIImage imageNamed:@"notepadHeader_iPad"];
            self.notepadHeaderLandscape = [UIImage imageNamed:@"notepadHeader_iPad_landscape"];
        } 
        else if (isPhone568)
        {
            self.notepadHeaderPortrait = [UIImage imageNamed:@"notepadHeader"];
            self.notepadHeaderLandscape = [UIImage imageNamed:@"notepadHeader_landscape-568h"];
        }
        else
        {
            self.notepadHeaderPortrait = [UIImage imageNamed:@"notepadHeader"];
            self.notepadHeaderLandscape = [UIImage imageNamed:@"notepadHeader_landscape"];
        }
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [_notepadHeader release];
    [_notepadFooter release];
    [_swipedIndexPath release];
    [_managedObjectContext release];
    [_fetchedResultsController release];    
    [_notepadHeaderPortrait release];
    [_notepadHeaderLandscape release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    TRC_ENTRY
}

#pragma mark - View lifecycle

- (void)updateNotepadImages:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        self.notepadHeader.image = self.notepadHeaderPortrait;
    }    
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        self.notepadHeader.image = self.notepadHeaderLandscape;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    TRC_ENTRY
    [UIUtils setBackgroundImage:self.view image:@"background"];
    [UIUtils setNavigationBarImage:self.navigationController.navigationBar];
    [UIUtils setNavigationBarTintColor:self.navigationController.navigationBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    TRC_ENTRY
    self.tableView = nil;
    self.notepadHeader = nil;
    self.notepadFooter = nil;
    self.swipedIndexPath = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self updateNotepadImages:self.interfaceOrientation];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.swipedIndexPath = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self updateNotepadImages:interfaceOrientation];    
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateNotepadImages:interfaceOrientation];
}

#pragma mark - Table date source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return (self.tableView.editing) ? YES : NO;
}

#pragma mark - Managed object context

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    self.managedObjectContext = [[PersistenceManager sharedPersistenceManager] managedObjectContext];
    return _managedObjectContext;
}

#pragma mark - Fetched result controller 

- (void)fetchedResultControllerInitialLoad
{
    if (!_fetchedResultsController)
    {
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) 
        {
            // Update to handle the error appropriately.
            NSLog(@"Error while initial loading of data %@, %@", error, [error userInfo]);
            exit(EXIT_FAILURE);
        }
        
        TRC_DBG(@"Fetched [%i] items", _fetchedResultsController.fetchedObjects.count);
    }
}

#pragma mark - Swipe cell actions

- (BOOL)cellIsSwiped:(NSIndexPath *)indexPath
{
    return (self.swipedIndexPath != nil && self.swipedIndexPath.row == indexPath.row && self.swipedIndexPath.section == indexPath.section);
}

- (void)reloadTableRows:(NSIndexPath *)indexPath withSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } 
    else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)cellWasSwiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]]; 
    if (indexPath == nil) 
    {
        return;
    } 
    else 
    { 
        if (self.swipedIndexPath == nil)
        {
            // no swipe before
            self.swipedIndexPath = indexPath;
            [self reloadTableRows:indexPath withSwipe:gestureRecognizer];
            
        } 
        else if ([self cellIsSwiped:indexPath])
        {
            // swipe the same cell
            self.swipedIndexPath = nil;
            [self reloadTableRows:indexPath withSwipe:gestureRecognizer];
        }
        else 
        {   
            // swipe another cell
            NSIndexPath *previosIndexPath = [self.swipedIndexPath retain];
            self.swipedIndexPath = nil;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previosIndexPath] withRowAnimation:NO];
            [self.tableView deselectRowAtIndexPath:previosIndexPath animated:NO];
            
            [previosIndexPath release];
            
            self.swipedIndexPath = indexPath;
            [self reloadTableRows:indexPath withSwipe:gestureRecognizer];
        }
    }
}

#pragma mark Update orders in all entries

- (void)updateOrder:(NSArray *)domains
{
    int i = 0;
    for (NSManagedObject *managedObject in domains)
    {
        [managedObject setValue:[NSNumber numberWithInt:i++] forKey:@"order"];
    }
}

- (NSNumber *)numberOfOccupationsWithDomain:(Domain *)domain andStatus:(NSNumber *)status
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Occupation" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"domain == %@ AND status == %@", domain, status]];
    
    NSArray *occupations = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    TRC_DBG(@"Number of items [%i] for domain [%@] and status [%i]", occupations.count, domain.text, [status intValue]);
    [fetchRequest release];
    
    return [NSNumber numberWithInt:occupations.count];
}

- (void)updateOccupationOrderForDomain:(Domain *)domain withStatus:(NSNumber *)status
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Occupation" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// sorting by order
	NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:orderDescriptor, nil]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"domain == %@ AND status == %@", domain, status]];
    
    NSArray *occupations = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    [self updateOrder:occupations];
    
    [fetchRequest release];
}

@end
