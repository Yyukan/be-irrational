//
//  TitleNoteViewController.m
//  GTI
//
//  Created by Oleksandr Shtykhno on 03/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//
#import "Common.h"
#import "TitleNoteViewController.h"

@implementation TitleNoteViewController

@synthesize textViewPlaceHolder = _textViewPlaceHolder;

@synthesize text = _text;
@synthesize note = _note;

@synthesize textView = _textView;
@synthesize noteView = _noteView;
@synthesize scrollView = _scrollView;

@synthesize object = _object;

@synthesize delegate;

#pragma mark - Initialize

- (id)initWithText:(NSString *)text andNote:(NSString *)note andObject:(NSManagedObject *)object    
{
    self = [super initWithNibName:@"TitleNoteViewController" bundle:nil];
    if (self) {
        self.text = text;
        self.note = note;
        self.object = object;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_textView release];
    [_noteView release];
    [_scrollView release];
    [_text release];
    [_note release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [UIUtils setBackgroundImage:self.view image:@"background"];
    
    self.navigationItem.title = NSLocalizedString(@"Title and Note", @"Title and note");
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)] autorelease];
    self.navigationController.navigationBar.tintColor = [UIUtils tintColor];
    
    [self.textView becomeFirstResponder];
    [self.textView setPlaceholder:NSLocalizedString(@"text", @"text")];
    [self.textView setText:self.text];
    [self.textView setDelegate:self];
    
    [self.noteView setText:self.note];
    [self.noteView setDelegate:self]; 
    
    self.textViewPlaceHolder = [UIUtils textView:self.noteView setPlaceholder:NSLocalizedString(@"note", @"note")];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.text = self.textView.text;
    self.note = self.noteView.text;
    
    self.textView = nil;
    self.noteView = nil;
    self.scrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        self.scrollView.scrollEnabled = NO;
    }    
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        self.scrollView.scrollEnabled = YES;
        self.scrollView.contentSize = CGSizeMake(320, 345);
    }    
    
    return YES;
}

#pragma mark - Text view delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self isTextViewPlaceHolder])
    {
        [UIUtils textViewRemovePlaceHolder:textView];
    }    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.textViewPlaceHolder = [UIUtils textView:self.noteView setPlaceholder:NSLocalizedString(@"note", @"note")];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.textViewPlaceHolder = NO;
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [self.delegate titleNoteViewControllerSave:self];
    return YES; 
}

#pragma mark - Providers

- (NSString *)provideText
{
    self.text = self.textView.text;
    return self.text;
} 

- (NSString *)provideNote
{
    self.note = ([self isTextViewPlaceHolder] ) ? @"" : self.noteView.text;
    return self.note;
} 

#pragma mark - IBAction

- (IBAction)cancel:(id)sender
{
    [self.delegate titleNoteViewControllerCancel:self];
}

- (IBAction)save:(id)sender
{
    TRC_ENTRY
    [self.delegate titleNoteViewControllerSave:self];
}

@end
