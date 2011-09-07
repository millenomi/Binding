//
//  ILBindingsEditorAppDelegate.m
//  BindingsEditor
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingsEditorAppDelegate.h"

#import "ILBinding.h"
#import "ILBindingsDocument.h"

@implementation ILBindingsEditorAppDelegate

- (void)applicationWillResignActive:(NSNotification *)notification;
{
    BOOL hasXcodeRunning = NO;
    
    for (NSRunningApplication* app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if ([app.bundleIdentifier isEqualToString:@"com.apple.dt.Xcode"]) {
            hasXcodeRunning = YES;
            break;
        }
    }
    
    if (hasXcodeRunning) {
        for (NSDocument* doc in [[NSDocumentController sharedDocumentController] documents]) {
            if ([doc isKindOfClass:[ILBindingsDocument class]] && doc.fileURL)
                [doc saveDocument:self];
        }
    }
}

@end
