//
//  SomedayViewController.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "SomedayViewController.h"
#import "Domain.h"
#import "Occupation.h"
#import "PersistenceManager.h"
#import "NoteViewController.h"

@implementation SomedayViewController

@synthesize swipeCell = _swipeCell;

- (id)init
{
    self = [super initWithNibName:@"BaseTabViewController" bundle:nil];
    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"Someday", @"Someday tab bar title");
        self.tabBarItem.image = [UIImage imageNamed:@"box"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    TRC_ENTRY    
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Someday", @"Someday view title");
    
    [self fetchedResultControllerInitialLoad];

    self.tableView.editing = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    TRC_ENTRY
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    TRC_ENTRY
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    TRC_ENTRY
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    TRC_DBG(@"Sections %i", self.fetchedResultsController.sections.count);
    return self.fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (SomedaySwipeCell *)cellWhenSwipe
{
    [[NSBundle mainBundle] loadNibNamed:@"SomedaySwipeCell" owner:self options:nil];
    SomedaySwipeCell *cell = _swipeCell;
    self.swipeCell = nil;
    
    [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionLeft target:self selector:@selector(cellWasSwiped:)]];
    [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionRight target:self selector:@selector(cellWasSwiped:)]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setSelected:NO];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self cellIsSwiped:indexPath])
    {
        return [self cellWhenSwipe];
    }

    static NSString *CellIdentifier = @"SomedayCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell.textLabel setFont:[UIUtils fontForDomainCell]];
        [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionLeft target:self selector:@selector(cellWasSwiped:)]];
        [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionRight target:self selector:@selector(cellWasSwiped:)]];
    }
    
    Occupation *occupation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = occupation.text;
    cell.detailTextLabel.text = occupation.note;
    return cell;
}

- (void)showCurrentOccupation:(NSIndexPath *)indexPath
{
    NSMutableArray *occupations = [self.fetchedResultsController.fetchedObjects mutableCopy];

    Occupation *occupation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NoteViewController *viewController = [[NoteViewController alloc] 
                                          initWithOccupation:occupation
                                          andOccupations:occupations
                                          andIndex:[occupations indexOfObject:occupation]];  
    viewController.showProgress = NO;

    [occupations release];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
    [viewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // prevent swiped cell from selection 
    if ([self cellIsSwiped:indexPath])
    {
        return;
    }
    
    [self showCurrentOccupation:indexPath];
}

#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (_fetchedResultsController != nil) 
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Occupation" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// sorting by order
	NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSSortDescriptor *textDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"domain.text" ascending:YES];

	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:textDescriptor, orderDescriptor, nil]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"status == %@", STATUS_OCCUPATION_SOMEDAY]];
	
	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"domain.text" cacheName:nil];
	
    self.fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
	
	[fetchedResultsController release];
	[fetchRequest release];
	
	return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    TRC_DBG(@"Before update [%i] entites", controller.fetchedObjects.count);
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath 
{
	UITableView *tableView = self.tableView;
    
	switch(type) 
    {
		case NSFetchedResultsChangeInsert:
            TRC_DBG(@"INSERT");
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			TRC_DBG(@"DELETE");
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
		case NSFetchedResultsChangeUpdate:
            TRC_DBG(@"UPDATE");
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:NO];
			break;
			
		case NSFetchedResultsChangeMove:
            TRC_DBG(@"MOVE");
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type 
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
            TRC_DBG(@"SECTION INSERT")
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
            TRC_DBG(@"SECTION DELETE")
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    [self.tableView endUpdates];
    
    TRC_DBG(@"After update [%i] entities", controller.fetchedObjects.count);
}

#pragma mark - Actions

- (void)updateOccupationStatus:(NSNumber *)status
{
    Occupation *occupation = [self.fetchedResultsController objectAtIndexPath:self.swipedIndexPath];
    
    occupation.order = [self numberOfOccupationsWithDomain:occupation.domain andStatus:status];
    occupation.status = status;

    [self updateOccupationOrderForDomain:occupation.domain withStatus:STATUS_OCCUPATION_SOMEDAY];    
    
    [[PersistenceManager sharedPersistenceManager] saveManagedContext];

    self.swipedIndexPath = nil;
    [self.tableView reloadData];
}

- (IBAction)nowButtonPressed:(id)sender
{
    [self updateOccupationStatus:STATUS_OCCUPATION_NORMAL];
}

- (IBAction)completedButtonPressed:(id)sender
{
    [self updateOccupationStatus:STATUS_OCCUPATION_COMPLETED];
}

- (IBAction)trashButtonPressed:(id)sender
{
    [self updateOccupationStatus:STATUS_OCCUPATION_TRASH];
}

@end
