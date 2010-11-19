//
//  HelloWorldAppDelegate.h
//  HelloWorld
//
//  Created by Jessica David on 10-09-14.
//  Copyright 2010 University of Toronto. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelloWorldAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MyViewController *myViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MyViewController *myViewController;

@end

