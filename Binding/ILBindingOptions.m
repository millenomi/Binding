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

@synthesize valueTransformer;

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

- (void)dealloc;
{
    [allowedThread release];
    [valueTransformer release];
    [super dealloc];
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

- (void)setDirection:(ILBindingDirection) d;
{
    if (direction != d) {
        direction = d;
        
        if (direction != kILBindingDirectionSourceToTargetOnly && self.valueTransformer && ![[self.valueTransformer class] allowsReverseTransformation])
            self.valueTransformer = nil;
    }
}

- (void)setValueTransformer:(NSValueTransformer *) v;
{
    if (v != valueTransformer) {
        [valueTransformer release];
        valueTransformer = [v retain];
        
        if (valueTransformer && ![[valueTransformer class] allowsReverseTransformation])
            self.direction = kILBindingDirectionSourceToTargetOnly;
    }
}

- (id)copyWithZone:(NSZone *)zone;
{
    ILBindingOptions* newOptions = [[ILBindingOptions allocWithZone:zone] init];
    
    newOptions->concurrencyModel = concurrencyModel;
        
    [newOptions->allowedThread autorelease];
    newOptions->allowedThread = [allowedThread retain];
    
    newOptions->direction = direction;
    
    [newOptions->valueTransformer autorelease];
    newOptions->valueTransformer = [valueTransformer retain];
        
    return newOptions;
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [self copyWithZone:zone];
}

@end
