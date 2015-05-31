//
//  TitleNoteViewController.h
//  GTI
//
//  Created by Oleksandr Shtykhno on 03/11/2011.
//  Copyright (c) 2011 shtykhno.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@protocol TitleNoteViewControllerDelegate;

@interface TitleNoteViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    @private
    BOOL _textViewPlaceHolder;
    NSString *_text;
    NSString *_note;
    
    UITextField *_textView;
    UITextView *_noteView;
}
@property (nonatomic, assign, getter=isTextViewPlaceHolder) BOOL textViewPlaceHolder;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *note;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *textView;
@property (nonatomic, retain) IBOutlet UITextView *noteView;    

@property (nonatomic, assign) NSManagedObject *object;
@property (nonatomic, assign) id <TitleNoteViewControllerDelegate> delegate;

- (id)initWithText:(NSString *)text andNote:(NSString *)note andObject:(NSManagedObject *)object;
- (NSString *)provideText;
- (NSString *)provideNote;

@end

@protocol TitleNoteViewControllerDelegate

- (void)titleNoteViewControllerSave:(TitleNoteViewController *)controller;
- (void)titleNoteViewControllerCancel:(TitleNoteViewController *)controller;

@end

