//
//  NoteViewController.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 06/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "NoteViewController.h"
#import "PersistenceManager.h"

#define NUMBER_OF_SECTIONS 1
#define NUMBER_OF_ROWS 4
#define ROW_TEXT 0
#define ROW_NOTE 1
#define ROW_PROGRESS 2
#define ROW_DATE 3

#define CELL_HEIGHT 44.0

@implementation NoteViewController

@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;
@synthesize trashButton = _trashButton;

@synthesize tableView = _tableView;
@synthesize notepadHeader = _notepadHeader;
@synthesize notepadFooter = _notepadFooter;
@synthesize occupation = _occupation;
@synthesize occupations = _occupations;

@synthesize titleCell = _titleCell;
@synthesize noteCell = _noteCell;
@synthesize progressCell = _progressCell;
@synthesize progressTextCell = _progressTextCell;
@synthesize flexibleCell = _flexibleCell;

@synthesize showEditButton = _showEditButton;
@synthesize showTrashButton = _showTrashButton;
@synthesize showProgress = _showProgress;

- (id)initWithOccupation:(Occupation *)occupation andOccupations:(NSMutableArray *)occupations andIndex:(int) index
{
    self = [super initWithNibName:@"NoteViewController" bundle:nil];
    if (self) {
        self.occupation = occupation;
        self.occupations = occupations;
        _index = index;
        
        _showTrashButton = YES;
        _showEditButton = YES;
        _showProgress = YES;
    }
    return self;
}

- (void)dealloc
{
    [_occupations release];
    
    [_progressCell release];
    [_progressTextCell release];
    [_titleCell release];
    [_noteCell release];

    [_previousButton release];
    [_nextButton release];
    [_trashButton release];
    [_tableView release];
    [_notepadHeader release];
    [_notepadFooter release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)disabledToolbarButtons
{
    if (_index == 0) {
        self.previousButton.enabled = NO;
    }
    if (_index == self.occupations.count - 1)
    {
        self.nextButton.enabled = NO;
    }
}

- (void)viewConfigure
{
    if (_showEditButton)
    {    
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)] autorelease];
    }
    if (!_showTrashButton)
    {
        self.trashButton.hidden = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIUtils setBackgroundImage:self.view image:@"background"];

    [self viewConfigure];
    
    self.navigationController.navigationBar.tintColor = [UIUtils tintColor];
    
    self.navigationItem.title = NSLocalizedString(@"Occupation", @"Occupation title");
    
    [self disabledToolbarButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.progressTextCell = nil;
    self.progressCell = nil;
    self.titleCell = nil;
    self.noteCell = nil;
    self.tableView = nil;
    self.previousButton = nil;
    self.nextButton = nil;
    self.trashButton = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.titleCell = nil;
    self.noteCell = nil;
    self.progressCell = nil;
    self.progressTextCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([Utils isDeviceAniPad])
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            self.notepadHeader.image = [UIImage imageNamed:@"notepadHeader_iPad"];
        }    
        else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
        {
            self.notepadHeader.image = [UIImage imageNamed:@"notepadHeader_iPad_landscape"];
        }    
    } 
    else
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            self.notepadHeader.image = [UIImage imageNamed:@"notepadHeader"];
        }    
        else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
        {
            if (isPhone568)
            {
                self.notepadHeader.image = [UIImage imageNamed:@"notepadHeader_landscape-568h"];
            }
            else
            {
                self.notepadHeader.image = [UIImage imageNamed:@"notepadHeader_landscape"];
            }
        }
    }
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.occupation.domain.text;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUMBER_OF_ROWS;
}

- (FlexibleCell *)cellForTitle:(NSIndexPath *)indexPath
{
    if (!self.titleCell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FlexibleCell" owner:self options:nil];
        self.titleCell = _flexibleCell;
        _flexibleCell = nil;
        
        self.titleCell.textView.font = [UIUtils fontForFlexibleCell];
    }   
    self.titleCell.textView.text = self.occupation.text;
    self.titleCell.iconView.image = [UIImage imageNamed:@"name"];

    return self.titleCell;
}

- (FlexibleCell *)cellForNote:(NSIndexPath *)indexPath
{
    if (!self.noteCell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FlexibleCell" owner:self options:nil];
        self.noteCell = _flexibleCell;
        _flexibleCell = nil;
        
        self.noteCell.textView.font = [UIUtils fontForFlexibleCell];
    }   
    self.noteCell.textView.text = self.occupation.note;
    self.noteCell.iconView.image = [UIImage imageNamed:@"note"];

    return self.noteCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) 
    {
        case ROW_TEXT:
        {
            return [[self cellForTitle:indexPath] heightForCell];
        }    
        case ROW_NOTE:
        {
            return [[self cellForNote:indexPath] heightForCell];
        }    
        default:
            return CELL_HEIGHT;
    }
} 

- (UITableViewCell *)cellForProgress:(NSIndexPath *)indexPath
{
    if (!self.progressCell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ProgressCell" owner:self options:nil];
    }   

    [self.progressCell updateProgressIcon:self.occupation.progress.floatValue];
    [self.progressCell updateProgressLabel:self.occupation.progress.floatValue];
    [self.progressCell.progressSlider setValue:self.occupation.progress.floatValue animated:NO];
    [self.progressCell.progressSlider addTarget:self action:@selector(sliderMoveEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressCell.progressSlider setMinimumTrackImage:[[UIImage imageNamed:@"brownslide.png"]
                                                            stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] 
                                                  forState:UIControlStateNormal];
    [self.progressCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (!_showProgress) 
    {
        [self.progressCell.progressSlider setEnabled:NO];
    }
    return self.progressCell;
}

- (UITableViewCell *)cellForDate:(NSIndexPath *)indexPath
{
    if (!self.progressTextCell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ProgressTextCell" owner:self options:nil];
    } 
    
    int days = [self.occupation completedDays];
    TRC_DBG(@"Completed days %i", days);
    [self.progressTextCell.label setFont:[UIUtils fontForDateCell]];
    [self.progressTextCell updateIconLabelInNumber:days];
    [self.progressTextCell updateIconImage:days * 10];
    [self.progressTextCell updateLabel:[DateUtils format:self.occupation.date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle]];
    [self.progressTextCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return self.progressTextCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) 
    {
        case ROW_TEXT:
            return [self cellForTitle:indexPath];
        case ROW_NOTE:
            return [self cellForNote:indexPath];
        case ROW_PROGRESS:
            return [self cellForProgress:indexPath];
        case ROW_DATE:
            return [self cellForDate:indexPath];
        default:
            break;
    }

    static NSString *CellIdentifier = @"NoteViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark Delegates

- (void)titleNoteViewControllerSave:(TitleNoteViewController *)controller
{
    self.occupation.text = [controller provideText];
    self.occupation.note = [controller provideNote];
    
    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

- (void)titleNoteViewControllerCancel:(TitleNoteViewController *)controller 
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - IBAction

- (IBAction)edit:(id)sender
{
    TitleNoteViewController *viewController = [[TitleNoteViewController alloc] initWithText:self.occupation.text andNote:self.occupation.note andObject:self.occupation];
    viewController.delegate = self;
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
	
    [viewController release];    
}

- (IBAction)previosNote:(id)sender
{
    self.nextButton.enabled = YES;
    _index--;
    self.occupation = [_occupations objectAtIndex:_index];
    
    [AnimationUtils animationTransition:self.view previosView:self.tableView nextView:self.tableView withTransition:UIViewAnimationTransitionCurlDown];
    [self.tableView reloadData];

    if (_index == 0)
    {
        self.previousButton.enabled = NO;
    }
    if (_index == _occupations.count - 1)
    {
        self.nextButton.enabled = NO;
    }
}

- (IBAction)nextNote:(id)sender
{
    self.previousButton.enabled = YES;
    _index++;
    self.occupation = [_occupations objectAtIndex:_index];
    
    [AnimationUtils animationTransition:self.view previosView:self.tableView nextView:self.tableView withTransition:UIViewAnimationTransitionCurlUp];
    [self.tableView reloadData];

    if (_index == _occupations.count - 1)
    {
        self.nextButton.enabled = NO;
    }
    if (_index == 0)
    {
        self.previousButton.enabled = NO;
    }
}

- (IBAction)trash:(id)sender
{
    self.occupation = [_occupations objectAtIndex:_index];
    
    self.occupation.status = STATUS_OCCUPATION_TRASH;

    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
    
    [_occupations removeObject:self.occupation];
    
    if (_occupations.count == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    } 
    else {
        if (_index == 0) {
            _index--;
            [self nextNote:sender];
        }
        else 
        {
            [self previosNote:sender];
        }    
    }
}

#pragma mark - UISlider actions

- (IBAction)progress:(UISlider *)slider
{
    [self.progressCell updateProgressIcon:slider.value];
    [self.progressCell updateProgressLabel:slider.value];
}

- (IBAction)sliderMoveEnd:(UISlider *)slider
{
    self.occupation.progress = [NSNumber numberWithFloat:slider.value];

    if ((int)slider.value == 100)
    {
        self.occupation.completedDate = [[Date instance] now];
    } 
    else 
    {
        self.occupation.completedDate = nil;
    }
    
    [[PersistenceManager sharedPersistenceManager] saveManagedContext];
}

@end
