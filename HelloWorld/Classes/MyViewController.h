//
//  MyViewController.h
//  HelloWorld
//
//  Created by Jessica David on 10-09-14.
//  Copyright 2010 University of Toronto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FliteTTS;

@interface MyViewController : UIViewController <UITextFieldDelegate> {
	UITextField *textField;
	UILabel *label;
	NSString *string;
	FliteTTS *fliteEngine;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, copy) NSString *string;
- (IBAction)changeGreeting:(id)sender;

@end
