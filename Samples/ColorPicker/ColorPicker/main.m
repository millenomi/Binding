//
//  main.m
//  ColorPicker
//
//  Created by ∞ on 05/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ILBindingsTestAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
    
    int i = UIApplicationMain(argc, argv, nil, NSStringFromClass([ILBindingsTestAppDelegate class]));
    
    [pool release];
    return i;
}
