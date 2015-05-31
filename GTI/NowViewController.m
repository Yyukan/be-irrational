//
//  NowViewController.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 01/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "NowViewController.h"
#import "TitleNoteViewController.h"
#import "NoteViewController.h"
#import "PersistenceManager.h"

@implementation NowViewController

@synthesize nowSwipeCell = _nowSwipeCell;
@synthesize progressTextCell = _progressTextCell;
@synthesize domain = _domain;

- (id)initWithDomain:(Domain *)domain
{
    self = [super initWithNibName:@"BaseTabViewController" bundle:nil];
    if (self) 
    {
        self.domain = domain;
        
        _swipedIndexPath = nil;
        _reordering = NO;
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
    TRC_ENTRY
    self.navigationItem.title = NSLocalizedString(@"Now I would", @"Now screen title");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)] autorelease];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    TRC_ENTRY
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.domain.text;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView.editing)
    {
        return [self.fetchedResultsController.fetchedObjects count] + 1;
    }    
    return self.fetchedResultsController.fetchedObjects.count;
}

- (NowSwipeCell *)cellWhenSwipe
{
    [[NSBundle mainBundle] loadNibNamed:@"NowSwipeCell" owner:self options:nil];
    NowSwipeCell *cell = _nowSwipeCell;
    self.nowSwipeCell = nil;
    
    [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionLeft target:self selector:@selector(cellWasSwiped:)]];
    [cell addGestureRecognizer:[Utils gestureWithDirection:UISwipeGestureRecognizerDirectionRight target:self selector:@selector(cellWasSwiped:)]];
    [cell setSelected:NO];
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
    static NSString *CellIdentifier = @"EditingOccupationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell.textLabel setFont:[UIUtils fontForDomainCell]];
        [cell setShowsReorderControl:YES];
    }
    
    Occupation *occupation = (Occupation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.detailTextLabel setText: occupation.note];
    [cell.textLabel setText:occupation.text];
    
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
    
    Occupation *occupation = (Occupation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell updateLabel:occupation.text];
    [cell updateIconImage:occupation.progress.intValue];
    [cell updateIconLabelInPercent:occupation.progress.intValue];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing)
    {
        if (indexPath.row == self.fetchedResultsController.fetchedObjects.count)
        {
            return [Utils tableView:tableView cellInsert:indexPath identifier:@"OccupationAddCell" text:@"add new occupation"];
        } 
    }    
    
    if (self.tableView.editing)
    {
        return [self tableView:tableView cellForEditing:indexPath];
    } 
    else 
    {
        if ([self cellIsSwiped:indexPath])
        {
            return [self cellWhenSwipe];
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
    NSManagedObject *item = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
    
    NSMutableArray *items = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    [items removeObject:item];
    [items insertObject:item atIndex:toIndexPath.row];
    
    [self updateOrder:items];
    
    TRC_DBG(@"Items: %@", items);
    [items release];
    
    _reordering = YES;
    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row >= self.fetchedResultsController.fetchedObjects.count) ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}

- (void)addNewOccupation:(NSIndexPath *)indexPath
{
    TitleNoteViewController *viewController = [[TitleNoteViewController alloc] initWithText:nil andNote:nil andObject:nil];
    viewController.delegate = self;
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    [viewController release];    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Occupation *occupation = [self.fetchedResultsController objectAtIndexPath:indexPath];

        occupation.order = [self numberOfOccupationsWithDomain:occupation.domain andStatus:STATUS_OCCUPATION_TRASH];
        occupation.status = STATUS_OCCUPATION_TRASH;

        [self updateOccupationOrderForDomain:occupation.domain withStatus:STATUS_OCCUPATION_NORMAL];    
        
        [[PersistenceManager sharedPersistenceManager] saveManagedContext];
    } 
    else 
    {
        if (editingStyle == UITableViewCellEditingStyleInsert)
        {
            if (indexPath.row == self.fetchedResultsController.fetchedObjects.count)
            {
                [self addNewOccupation:indexPath];
            }
        }
    }
}

- (void)editCurrentOccupation:(NSIndexPath *)indexPath
{
    Occupation *occupation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    TitleNoteViewController *viewController = [[TitleNoteViewController alloc] initWithText:occupation.text andNote:occupation.note andObject:occupation];
    viewController.delegate = self;
    
    [self.navigationController pushViewController:viewController animated:YES];
	
    [viewController release];    
}

- (void)showCurrentOccupation:(NSIndexPath *)indexPath
{
    NSMutableArray *occupations = [self.fetchedResultsController.fetchedObjects mutableCopy];
    Occupation *occupation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NoteViewController *viewController = [[NoteViewController alloc] 
                                          initWithOccupation:occupation
                                          andOccupations:occupations
                                          andIndex:[occupations indexOfObject:occupation]];  
    [occupations release];

    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
    [viewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing)
    {
        if (indexPath.row == self.fetchedResultsController.fetchedObjects.count)
        {
            [self addNewOccupation:indexPath];
        }
        else
        {
            [self editCurrentOccupation:indexPath];
        }
    }
    else 
    {
        // prevent swiped cell from selection 
        if ([self cellIsSwiped:indexPath])
        {
            return;
        }
        
        [self showCurrentOccupation:indexPath];    
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Trash", @"Trash");
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
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:orderDescriptor, nil]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"domain == %@ AND status == %@", self.domain, STATUS_OCCUPATION_NORMAL]];
	
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
    
    Occupation *occupation;
    if ([controller object])
    {
        occupation = (Occupation *)controller.object;
    } 
    else
    {
        // create managed entity
        occupation = [NSEntityDescription insertNewObjectForEntityForName:@"Occupation" inManagedObjectContext:self.managedObjectContext];
        occupation.date = [[Date instance] now];
        occupation.order = [NSNumber numberWithInteger:self.fetchedResultsController.fetchedObjects.count];
        occupation.status = STATUS_OCCUPATION_NORMAL;
    }
    
    occupation.text = [controller provideText];
    occupation.note = [controller provideNote];
    occupation.domain = self.domain;
    
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
    [self editCurrentOccupation:self.swipedIndexPath];
}

- (void)updateOccupationStatus:(NSNumber *)status
{
    Occupation *occupation = [self.fetchedResultsController objectAtIndexPath:self.swipedIndexPath];
    
    occupation.order = [self numberOfOccupationsWithDomain:occupation.domain andStatus:status];
    occupation.status = status;
    
    [self updateOccupationOrderForDomain:occupation.domain withStatus:STATUS_OCCUPATION_NORMAL];    

    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
    self.swipedIndexPath = nil;
    
    [self.tableView reloadData];
}

- (IBAction)completedButtonPressed:(id)sender
{
    [self updateOccupationStatus:STATUS_OCCUPATION_COMPLETED];
}

- (IBAction)somedayButtonPressed:(id)sender
{
    [self updateOccupationStatus:STATUS_OCCUPATION_SOMEDAY];
}

- (IBAction)trashButtonPressed:(id)sender
{
    [self updateOccupationStatus:STATUS_OCCUPATION_TRASH];
}

@end
