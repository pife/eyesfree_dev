/*
    File: MyView.m
Abstract: MyView several subviews, each of which can be moved by gestures. Illustrates handling gesture events, incluing multiple gestures.
 Version: 1.12

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2010 Apple Inc. All Rights Reserved.

 */

#import <QuartzCore/QuartzCore.h>
#import "MyView.h"

@implementation MyView

@synthesize firstPieceView;
@synthesize secondPieceView;
@synthesize thirdPieceView;
@synthesize touchPhaseText;
@synthesize touchInfoText;
@synthesize touchTrackingText;
@synthesize touchInstructionsText;



#pragma mark -
#pragma mark === Setting up and tearing down ===
#pragma mark

// adds a set of gesture recognizers to one of our piece subviews
- (void)addGestureRecognizersToPiece:(UIView *)piece
{
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [piece addGestureRecognizer:rotationGesture];
    [rotationGesture release];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [piece addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
    [panGesture release];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showResetMenu:)];
    [piece addGestureRecognizer:longPressGesture];
    [longPressGesture release];
}

- (void)awakeFromNib
{
    [self addGestureRecognizersToPiece:firstPieceView];
    [self addGestureRecognizersToPiece:secondPieceView];
    [self addGestureRecognizersToPiece:thirdPieceView];
}

// Releases necessary resources. 
-(void)dealloc
{
	// Release each of the subviews
	[firstPieceView release];
	[secondPieceView release];
	[thirdPieceView release];
	// Release the labels
	[touchInfoText release];
	[touchPhaseText release];
	[touchInstructionsText release];
	[touchTrackingText release];
	[super dealloc];	
}

#pragma mark -
#pragma mark === Utility methods  ===
#pragma mark

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

// display a menu with a single item to allow the piece's transform to be reset
- (void)showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
	touchInfoText.text = @"PRESS!";
	
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Reset" action:@selector(resetPiece:)];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        pieceForReset = [gestureRecognizer view];
        
        [resetMenuItem release];
    }
}

// animate back to the default anchor point and transform
- (void)resetPiece:(UIMenuController *)controller
{
    CGPoint locationInSuperview = [pieceForReset convertPoint:CGPointMake(CGRectGetMidX(pieceForReset.bounds), CGRectGetMidY(pieceForReset.bounds)) toView:[pieceForReset superview]];
    
    [[pieceForReset layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    [pieceForReset setCenter:locationInSuperview];
    
    [UIView beginAnimations:nil context:nil];
    [pieceForReset setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
}

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{

    UIView *piece = [gestureRecognizer view];
	
	if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
		
		// TODO: Play selected Character Sound
		
		// TODO: Append selected character to Output String
		
		
		// Reset variables
		letterx = 0.0;
		lettery = 0.0;
		characterx = 0.0;
		charactery = 0.0;
		letterSwitch = 0;
	}
		
	
	// PIF: Get the First Move of the gesture
	// Postive X if Clockwise
	// Negatve Y is Counter-Clockwise 
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		
		
		// PIF: get the direction, set the BOOLEAN. (Method 1: Translation)
		// ERROR: ZERO is a possible translation value (defaults to Counter-Clockwise)
		/* 
		CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
		if (translation.x > 0) {
			isClockwise = TRUE;
		 
			// Set start point to ascii 'a'
			charSelect = 97;
		 
			// TODO: Play Character sound
			
			//PIF: For Testing
			touchPhaseText.text = @"CLOCKWISE!";

		} else {
			isClockwise = FALSE;
		 
			// Set start point to ascii 'z'
			charSelect = 122;
		 
			// TODO: Play Character sound
			
			//PIF: For Testing
			touchPhaseText.text = @"Counter CLOCKWISE!";
		}
 
		//PIF: For Testing
		NSString *transInfo = [[NSString alloc] initWithFormat:@"First %fx, %fy", translation.x, translation.y];
		touchInfoText.text = transInfo;
		[transInfo release];
		*/
		
		// PIF: get the direction, set the BOOLEAN. (Method 2: Velocity)
		// ERROR: ZERO is a possible translation value (defaults to Counter-Clockwise)
		CGPoint velocity = [gestureRecognizer velocityInView:[piece superview]];
		if (velocity.x > 0.0) {
			isClockwise = TRUE;
			
			// Set start point to ascii 'a'
			charSelect = 97;
			
			// TODO: Play Character sound
			
			//PIF: For Testing
			touchPhaseText.text = @"CLOCKWISE!";
			
		} else {
			isClockwise = FALSE;
			
			// Set start point to ascii 'z'
			charSelect = 122;
			
			// TODO: Play Character sound
			
			//PIF: For Testing
			touchPhaseText.text = @"Counter CLOCKWISE!";
		}
		
		//PIF: for Testing - Velocity
		NSString *veloInfo = [[NSString alloc] initWithFormat:@"First %fx, %fy", velocity.x, velocity.y];
		touchInfoText.text = veloInfo;
		[veloInfo release];
		
	}
		
	////PIF: for Testing
	//touchInfoText.text = @"PAN!";
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
		
		// PIF: These are the gesture attributes
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
		CGPoint velocity = [gestureRecognizer velocityInView:[piece superview]];
		//CGPoint location = [gestureRecognizer locationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
		
		//PIF: for Testing
		//NSString *transInfo = [[NSString alloc] initWithFormat:@"Translation %fx, %fy", translation.x, translation.y];
		//touchInstructionsText.text = transInfo;
		//[transInfo release];
		
		////PIF: for Testing - Location
		//NSString *locaInfo = [[NSString alloc] initWithFormat:@"Location %fx, %fy", location.x, location.y];
		//touchTrackingText.text = locaInfo;
		//[locaInfo release];
		
		//PIF: for Testing - Velocity
		NSString *veloInfo = [[NSString alloc] initWithFormat:@"Velocity %fx, %fy", velocity.x, velocity.y];
		touchInstructionsText.text = veloInfo;
		[veloInfo release];
		
		// PIF: gesture velocity accumulator
		letterSwitch += fabs(velocity.x) + fabs(velocity.y);
		
		////PIF: for Testing - Accumulator
		//NSString *letterInfo = [[NSString alloc] initWithFormat:@"Accumulator %f.", letterSwitch];
		//touchPhaseText.text = letterInfo;
		//[letterInfo release];
		
		// PIF: This checks for reversal of Direction (Method 1)
		// ERROR: This lazy way almost works
		//if ((letterx * translation.x < 0) || (lettery * translation.y < 0)) {
		//	
		//	// PIF: Then swap direction
		//	if (isClockwise == FALSE) {
		//		isClockwise = TRUE;
		//		// PIF: For Testing
		//		touchPhaseText.text = @"Clockwise";
		//	} else {
		//		isClockwise = FALSE;
		//		touchPhaseText.text = @"Counter Clockwise";
		//	}
		//}
		
		 //PIF: This checks for reversal of Direction (Method 2)
		 //ERROR: This lazy way almost works better
		if ((characterx * velocity.x < 0.0) || (charactery * velocity.y < 0.0)) {
			
			// PIF: Then swap direction
			if (isClockwise == FALSE) {
				isClockwise = TRUE;
				// PIF: For Testing
				touchPhaseText.text = @"Clockwise";
			} else {
				isClockwise = FALSE;
				touchPhaseText.text = @"Counter Clockwise";
			}
		}
		
		// PIF: Accumulator threshold test to signal new character event
		if (letterSwitch > 1000) {
			
			// PIF: reset the Accumulator to ziltch.
			letterSwitch = 0;
			
			// PIF: Save the gesture direction (Method 1)
			//letterx = translation.x;
			//lettery = translation.y;
			
			//PIF: for Testing
			//NSString *directInfo = [[NSString alloc] initWithFormat:@"Last Direction %3.3fx, %3.3fy", letterx, lettery];
			//touchTrackingText.text = directInfo;
			//[directInfo release];
			
			// PIF: Save the gesture direction (Method 2)
			characterx = velocity.x;
			charactery = velocity.y;
			
			
			// PIF: Change Character
			// Select next Character
			if (isClockwise) {
				charSelect++;
				if (charSelect > 122) {
					charSelect = 97;
				}
			} else {
				charSelect--;
				if (charSelect < 97) {
					charSelect = 122;
				}
			}
			
			// TODO: Add Sound of Character
			

		}
		
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
    }
}

// ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously
// prevent other gesture recognizers from recognizing simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // if the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition
    if (gestureRecognizer.view != firstPieceView && gestureRecognizer.view != secondPieceView && gestureRecognizer.view != thirdPieceView)
        return NO;
    
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}

@end
