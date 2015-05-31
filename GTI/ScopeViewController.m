//
//  ScopeViewController.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "ScopeViewController.h"
#import "NowViewController.h"
#import "PredefinedScopeViewController.h"
#import "PersistenceManager.h"
#import "Domain.h"

#define SCOPE_NUMBER_OF_SECTIONS 1

@implementation ScopeViewController

@synthesize scopeSwipeCell = _scopeSwipeCell;
@synthesize progressTextCell = _progressTextCell;

- (id)init
{
    self = [super initWithNibName:@"BaseTabViewController" bundle:nil];
    if (self) 
    {
        TRC_ENTRY
        self.tabBarItem.title = NSLocalizedString(@"Now", @"Now tab bar title");
        self.tabBarItem.image = [UIImage imageNamed:@"now"];
        
        _reordering = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
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
    TRC_ENTRY
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)] autorelease];
    self.navigationItem.title = NSLocalizedString(@"Now", @"Scope view title");
    
    self.navigationController.navigationBar.tintColor = [UIUtils tintColor];
    
    [self fetchedResultControllerInitialLoad];
    
    self.tableView.editing = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
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

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SCOPE_NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView.editing)
    {
        return [self.fetchedResultsController.fetchedObjects count] + 2;
    }    
    return self.fetchedResultsController.fetchedObjects.count;
}

- (ScopeSwipeCell *)cellWhenSwipe:(NSIndexPath *)indexPath
{
    [[NSBundle mainBundle] loadNibNamed:@"ScopeSwipeCell" owner:self options:nil];
    ScopeSwipeCell *cell = _scopeSwipeCell;
    self.scopeSwipeCell = nil;
    
    [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionLeft target:self selector:@selector(cellWasSwiped:)]];
    [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionRight target:self selector:@selector(cellWasSwiped:)]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setSelected:NO];
    
    Domain *domain = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (![domain hasOccupationsInStatusNormal])
    {
        cell.somedayButton.enabled = NO;
        cell.completeButton.enabled = NO;
        cell.trashButton.enabled = NO;
    }
    
    return cell;
}

- (ProgressTextCell *)loadProgressTextCell:(NSIndexPath *)indexPath
{
    [[NSBundle mainBundle] loadNibNamed:@"ProgressTextCell" owner:self options:nil];
    
    ProgressTextCell *cell = _progressTextCell;
    _progressTextCell = nil;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForEditing:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EditingScopeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell.textLabel setFont:[UIUtils fontForDomainCell]];
        [cell setShowsReorderControl:YES];
    }
    
    Domain *domain = (Domain *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.detailTextLabel setText:domain.note];
    [cell.textLabel setText:domain.text];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForViewing:(NSIndexPath *)indexPath
{
    ProgressTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgressTextCell"];
    if (cell == nil) 
    {
        cell = [self loadProgressTextCell:indexPath];
        [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionLeft target:self selector:@selector(cellWasSwiped:)]];
        [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionRight target:self selector:@selector(cellWasSwiped:)]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:GLOBAL_CELL_SELECTION_STYLE];
    }
    
    Domain *domain = (Domain *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell updateLabel:domain.text];
    [cell updateIconLabelInNumber:[domain numberOfOccupations]];
    [cell updateIconImage:[domain numberOfOccupations] * 10];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing)
    {
        if (indexPath.row == self.fetchedResultsController.fetchedObjects.count)
        {
            return [Utils tableView:tableView cellInsert:indexPath identifier:@"ScopeAddCell" text:@"add new scope"];
        } 
        if (indexPath.row == self.fetchedResultsController.fetchedObjects.count + 1)
        {
            return [Utils tableView:tableView cellInsert:indexPath identifier:@"ScopePredefinedAddCell" text:@"add predefined scope"];
        }
        return [self tableView:tableView cellForEditing:indexPath];
    } 
    else 
    {
        if ([self cellIsSwiped:indexPath])
        {
            return [self cellWhenSwipe:indexPath];
        }

        return [self tableView:tableView cellForViewing:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row >= self.fetchedResultsController.fetchedObjects.count) ? NO : YES;
}

- (NSIndexPath *) tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSIndexPath *target = proposedDestinationIndexPath;
    NSUInteger schedulesCount = self.fetchedResultsController.fetchedObjects.count - 1;
    
    if (proposedDestinationIndexPath.row > schedulesCount) 
    {
        target = [NSIndexPath indexPathForRow:schedulesCount inSection:0];
    }   
	
    return target;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSManagedObject *domain = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    
    NSMutableArray *domains = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    [domains removeObject:domain];
    [domains insertObject:domain atIndex:toIndexPath.row];
    
    [self updateOrder:domains];
    
    [domains release];
    
    _reordering = YES;
    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row >= self.fetchedResultsController.fetchedObjects.count) ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}

- (void)addNewScope:(NSIndexPath *)indexPath
{
    TitleNoteViewController *viewController = [[TitleNoteViewController alloc] initWithText:nil andNote:nil andObject:nil];
    viewController.delegate = self;
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    [viewController release];    
}

- (void)editCurrentScope:(NSIndexPath *)indexPath
{
    Domain *domain = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    TitleNoteViewController *viewController = [[TitleNoteViewController alloc] initWithText:domain.text andNote:domain.note andObject:domain];
    viewController.delegate = self;
    
    [self.navigationController pushViewController:viewController animated:YES];
	
    [viewController release];    
}

- (void)addPredefinedScope:(NSIndexPath *)indexPath
{
    NSMutableArray *domains = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
    PredefinedScopeViewController *controller = [[PredefinedScopeViewController alloc] initWithDomains:domains];
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];
    [domains release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.swipedIndexPath = indexPath;
        [Utils showDeleteCancelAction:self.tableView deleteCaption:@"Delete Scope" cancelCaption:@"Cancel" delegate:self tag:ACTION_SHEET_DELETE_SCOPE_TAG];
    } 
    else 
    {
        if (editingStyle == UITableViewCellEditingStyleInsert)
        {
            if (indexPath.row == self.fetchedResultsController.fetchedObjects.count)
            {
                [self addNewScope:indexPath];
            }
            else if (indexPath.row == self.fetchedResultsController.fetchedObjects.count + 1)
            {
                [self addPredefinedScope:indexPath];
            } 
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing)
    {
        if (indexPath.row == self.fetchedResultsController.fetchedObjects.count)
        {
            [self addNewScope:indexPath];
        }
        else if (indexPath.row == self.fetchedResultsController.fetchedObjects.count + 1)
        {
            [self addPredefinedScope:indexPath];
        } 
        else
        {
            [self editCurrentScope:indexPath];
        }
    }
    else 
    {
        // prevent swiped cell from selection 
        if ([self cellIsSwiped:indexPath])
        {
            return;
        }
        
        Domain *domain = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        
        NowViewController *nowViewController = [[NowViewController alloc] initWithDomain:domain];
        
        [self.navigationController pushViewController:nowViewController animated:YES];
        
        [nowViewController release];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NSLocalizedString(@"Delete", @"Delete");
}

#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Domain" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// sorting by order
	NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:orderDescriptor, nil]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"status == %@", STATUS_DOMAIN_NORMAL]];

	
	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	
    self.fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
	
	[fetchedResultsController release];
	[fetchRequest release];
	
	return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    if (_reordering) 
    {
        return;
    } 
    
    TRC_DBG(@"Before update [%i] entites", controller.fetchedObjects.count);
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath 
{
    if (_reordering)
    {
        return;
    }    
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    if (_reordering) 
    {
        _reordering = NO;
        return;
    } 
    [self.tableView endUpdates];
    
    TRC_DBG(@"After update [%i] entities", controller.fetchedObjects.count);
}


#pragma mark Delegates

- (void)titleNoteViewControllerSave:(TitleNoteViewController *)controller
{
    TRC_ENTRY
    Domain *domain;
    if ([controller object])
    {
        domain = (Domain *)controller.object;
    } 
    else
    {
        // create managed entity
        domain = [NSEntityDescription insertNewObjectForEntityForName:@"Domain" inManagedObjectContext:self.managedObjectContext];
        domain.date = [[Date instance] now];
        domain.order = [NSNumber numberWithInt:self.fetchedResultsController.fetchedObjects.count];
        domain.status = STATUS_DOMAIN_NORMAL;
    }
    
    domain.text = [controller provideText];
    domain.note = [controller provideNote];
    
    TRC_DBG(@"Objects in the list [%i]", self.fetchedResultsController.fetchedObjects.count);
    // save managed context when insert new record 
    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)titleNoteViewControllerCancel:(TitleNoteViewController *)controller 
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{   
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)] autorelease];
    self.swipedIndexPath = nil;
    _reordering = NO;
    
    self.tableView.editing = NO;
    
    [self.tableView reloadData];
}

- (IBAction)edit:(id)sender
{
    TRC_ENTRY
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
    self.swipedIndexPath = nil;
    _reordering = NO;

    self.tableView.editing = YES;

    [self.tableView reloadData];
}

- (IBAction)editButtonPressed:(id)sender
{
    [self editCurrentScope:self.swipedIndexPath];
}

- (void)updateOccupationsStatus:(NSNumber *)status
{
    Domain *domain = [self.fetchedResultsController objectAtIndexPath:self.swipedIndexPath];
    
    if ([domain hasOccupations])
    {
        int changed = 0;
        for (Occupation *occupation in domain.occupations)
        {
            if (occupation.status.intValue == STATUS_OCCUPATION_NORMAL.intValue)
            {
                occupation.order = [self numberOfOccupationsWithDomain:occupation.domain andStatus:status];
                occupation.status = status;
                changed++;
            }
        }
        if (changed > 0)
        {    
            [[PersistenceManager sharedPersistenceManager] saveManagedContext];
        }    
    }    

    NSIndexPath *previosIndexPath = [self.swipedIndexPath retain];
    self.swipedIndexPath = nil;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previosIndexPath] withRowAnimation:NO];
    [previosIndexPath release];
}

- (IBAction)completedButtonPressed:(id)sender
{
    [Utils showDeleteCancelAction:self.tableView deleteCaption:@"Move All To Completed" cancelCaption:@"Cancel" delegate:self tag:ACTION_SHEET_MOVE_OCCUPATION_COMPLETED_TAG];
}

- (IBAction)somedayButtonPressed:(id)sender
{
    [Utils showDeleteCancelAction:self.tableView deleteCaption:@"Move All To Someday" cancelCaption:@"Cancel" delegate:self tag:ACTION_SHEET_MOVE_OCCUPATION_SOMEDAY_TAG];
}

- (IBAction)trashButtonPressed:(id)sender
{
    [Utils showDeleteCancelAction:self.tableView deleteCaption:@"Trash All Occupations" cancelCaption:@"Cancel" delegate:self tag:ACTION_SHEET_TRASH_OCCUPATION_TAG];
}

- (void)deleteScope
{
    Domain *domain = [self.fetchedResultsController objectAtIndexPath:self.swipedIndexPath];

    for (Occupation *occupation in domain.occupations)
    {
        [self.managedObjectContext deleteObject:occupation];

        TRC_DBG(@"Deleted occupation [%@]", occupation.text);
    }   
    
    [self.managedObjectContext deleteObject:domain];

    TRC_DBG(@"Deleted domain [%@]", domain.text);

    NSMutableArray *domains = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    // remove object from fetched result controller
    [domains removeObject:domain];
    // update order
    [self updateOrder:domains];

    [domains release];
    
    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    switch (actionSheet.tag)
    {
        case ACTION_SHEET_TRASH_OCCUPATION_TAG:
            switch (buttonIndex) {
                case 0:
                    [self updateOccupationsStatus:STATUS_OCCUPATION_TRASH];
                    break;
                    
                default:
                    return;
            }
            break;
            
        case ACTION_SHEET_DELETE_SCOPE_TAG:
            switch (buttonIndex) {
                case 0:
                    [self deleteScope];
                    self.swipedIndexPath = nil;
                    break;
                case 1:
                    self.swipedIndexPath = nil;
                    break;
                default:
                    return;
            }
            break;
        case ACTION_SHEET_MOVE_OCCUPATION_SOMEDAY_TAG:
            switch (buttonIndex) {
                case 0:
                    [self updateOccupationsStatus:STATUS_OCCUPATION_SOMEDAY];
                    break;
                    
                default:
                    return;
            }
            break;
        case ACTION_SHEET_MOVE_OCCUPATION_COMPLETED_TAG:
            switch (buttonIndex) {
                case 0:
                    [self updateOccupationsStatus:STATUS_OCCUPATION_COMPLETED];
                    break;
                    
                default:
                    return;
            }
            break;
            
        default:
            return;
    }
    
}


@end
