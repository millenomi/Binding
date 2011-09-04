//
//  ILBindingOptions.m
//  Binding
//
//  Created by ∞ on 04/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingOptions.h"

@implementation ILBindingOptions

@synthesize concurrencyModel, allowedThread;

+ optionsWithDefaultValues;
{
    return [[self new] autorelease];
}

- (id)init;
{
    self = [super init];
    if (self) {
        self.concurrencyModel = kILBindingConcurrencyAllowedThread;
    }
    return self;
}

- (void)setConcurrencyModel:(ILBindingConcurrencyModel) m;
{
    concurrencyModel = m;
    
    switch (concurrencyModel) {
        case kILBindingConcurrencyAllowedThread:
            
            if (!self.allowedThread)
                self.allowedThread = [NSThread mainThread];
            
            break;
    }
}

- (id)copyWithZone:(NSZone *)zone;
{
    ILBindingOptions* newOptions = [[ILBindingOptions allocWithZone:zone] init];
    newOptions->concurrencyModel = concurrencyModel;

    [newOptions->allowedThread autorelease];
    newOptions->allowedThread = [allowedThread retain];
    
    return newOptions;
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [self copyWithZone:zone];
}

@end
