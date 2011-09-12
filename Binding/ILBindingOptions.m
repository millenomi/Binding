//
//  ILBindingOptions.m
//  Binding
//
//  Created by ∞ on 04/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILBindingOptions.h"

@implementation ILBindingOptions

@synthesize concurrencyModel, allowedThread, dispatchQueue;

@synthesize direction;

@synthesize valueTransformer;

- init { return [super init]; }

+ optionsWithDefaultValues;
{
    return [[self new] autorelease];
}

- (void)dealloc;
{
    if (dispatchQueue)
        dispatch_release(dispatchQueue);
    
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
                                
                self.dispatchQueue = NULL;
                break;
                
            case kILBindingConcurrencyDispatchOnQueue:
                
                self.allowedThread = nil;
                break;
                
        }
    }
}

- (NSThread *)allowedThread;
{
    if (!allowedThread)
        return [NSThread mainThread];
    
    return allowedThread;
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

- (dispatch_queue_t)dispatchQueue;
{
    if (!dispatchQueue)
        return dispatch_get_main_queue();
    
    return dispatchQueue;
}

- (void)setDispatchQueue:(dispatch_queue_t) dq;
{
    if (dispatchQueue != dq) {
        dispatch_release(dispatchQueue);
        if (dq)
            dispatch_retain(dq);
        
        dispatchQueue = dq;
        
        if (dq)
            self.concurrencyModel = kILBindingConcurrencyDispatchOnQueue;
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
    
    if (newOptions->dispatchQueue && newOptions->dispatchQueue != dispatchQueue)
        dispatch_release(newOptions->dispatchQueue);
    if (dispatchQueue)
        dispatch_retain(dispatchQueue);
    
    newOptions->dispatchQueue = dispatchQueue;
        
    return newOptions;
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [self copyWithZone:zone];
}

@end
