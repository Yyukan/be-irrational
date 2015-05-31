//
//  PredefinedScopeViewController.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 19/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "Domain.h"
#import "PredefinedScopeViewController.h"
#import "PersistenceManager.h"

@implementation PredefinedScopeViewController

- (id)initWithDomains:(NSArray *)domains
{
    self = [super initWithNibName:@"BaseTabViewController" bundle:nil];
    if (self) 
    {
        PredefinedScope *scope1 = [[PredefinedScope alloc] initWithTitle:@"Sort out my finances" andNote:@"total income, savings, debt repayment"];
        PredefinedScope *scope2 = [[PredefinedScope alloc] initWithTitle:@"Take up career and business" andNote:@"new projects, partnerships, expansion, new products/services"];
        PredefinedScope *scope3 = [[PredefinedScope alloc] initWithTitle:@"Take care of my health" andNote:@"weight loss/gain, training, eating habits, medicine, sports"];
        PredefinedScope *scope4 = [[PredefinedScope alloc] initWithTitle:@"Develop myself" andNote:@"education, training, public speaking, counseling, spiritual values"];
        PredefinedScope *scope5 = [[PredefinedScope alloc] initWithTitle:@"Improve family relationship" andNote:@"family, children, parents, friends, partners"];
        PredefinedScope *scope6 = [[PredefinedScope alloc] initWithTitle:@"Arrange my free time" andNote:@"holidays, travel, clubs, hobbies, activities"];
        PredefinedScope *scope7 = [[PredefinedScope alloc] initWithTitle:@"Participate in public life" andNote:@"charity, public affairs, church, coaching"];
        PredefinedScope *scope8 = [[PredefinedScope alloc] initWithTitle:@"Improve foreign languages" andNote:@"reading books, magazines, writing articles"];

        _predefinedScopes = [[NSArray arrayWithObjects:scope1, scope2, scope3, scope4, scope5, scope6, scope7, scope8, nil] retain];
        _domains = [domains retain];
        
        [scope1 release];
        [scope2 release];
        [scope3 release];
        [scope4 release];
        [scope5 release];
        [scope6 release];
        [scope7 release];
        [scope8 release];
    }
    return self;
}

- (void)dealloc
{
    [_domains release];
    [_predefinedScopes release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.title = NSLocalizedString(@"Predefined", @"Predefined title");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _predefinedScopes.count;
}

- (BOOL)scopeAlreadyInDomain:(PredefinedScope *)scope
{
    for (Domain *domain in _domains)
    {
        if ([scope.title isEqualToString:domain.text] && [scope.note isEqualToString:domain.note])
        {
            scope.checked = YES;
            return YES;
        }    
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PredefinedScopeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell.textLabel setFont:[UIUtils fontForDomainCell]];
    }

    PredefinedScope *scope = [_predefinedScopes objectAtIndex:indexPath.row];

    if ([self scopeAlreadyInDomain:scope])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell.textLabel setText:scope.title];
    [cell.detailTextLabel setText:scope.note];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PredefinedScope *scope = [_predefinedScopes objectAtIndex:indexPath.row];    

    if (!scope.checked)
    {
        Domain *domain = [NSEntityDescription insertNewObjectForEntityForName:@"Domain" inManagedObjectContext:self.managedObjectContext];
        domain.date = [[Date instance] now];
        domain.order = [NSNumber numberWithInt:_domains.count];
        domain.status = STATUS_DOMAIN_NORMAL;
        
        domain.text = scope.title;
        domain.note = scope.note;
        
        [[PersistenceManager sharedPersistenceManager] saveManagedContext];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

@implementation PredefinedScope

@synthesize title = _title;
@synthesize note = _note;
@synthesize checked = _checked;

- (id)initWithTitle:(NSString *)title andNote:(NSString *)note;
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.note = note;
        _checked = NO;
    }
    return self;
}

- (void) dealloc
{
    [_title release];
    [_note release];
    [super dealloc];
}

@end