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

@synthesize direction;

+ optionsWithDefaultValues;
{
    return [[self new] autorelease];
}

- (id)init;
{
    self = [super init];
    if (self) {
        self.allowedThread = [NSThread mainThread];
    }
    return self;
}

- (void)setConcurrencyModel:(ILBindingConcurrencyModel) m;
{
    if (concurrencyModel != m) {
        concurrencyModel = m;
        
        switch (concurrencyModel) {
            case kILBindingConcurrencyAllowedThread:
                
                if (!self.allowedThread)
                    self.allowedThread = [NSThread mainThread];
                
                break;
        }
    }
}

- (void)setAllowedThread:(NSThread *) a;
{
    if (a != allowedThread) {
        [allowedThread release];
        allowedThread = [a retain];
        
        if (allowedThread)
            self.concurrencyModel = kILBindingConcurrencyAllowedThread;
    }
}

- (id)copyWithZone:(NSZone *)zone;
{
    ILBindingOptions* newOptions = [[ILBindingOptions allocWithZone:zone] init];
    
    newOptions->concurrencyModel = concurrencyModel;
        
    [newOptions->allowedThread autorelease];
    newOptions->allowedThread = [allowedThread retain];
    
    newOptions->direction = direction;
    
    return newOptions;
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [self copyWithZone:zone];
}

@end
