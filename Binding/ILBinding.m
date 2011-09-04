//
//  ILBinding.m
//  Binding
//
//  Created by ∞ on 03/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBinding.h"

@interface ILBinding ()

@property(assign, nonatomic) id firstObject, secondObject;
@property(copy, nonatomic) NSString* firstKey, * secondKey;

@property(copy, nonatomic) ILBindingOptions* options;

@property(nonatomic, getter = isSynchronizing) BOOL synchronizing;

@end


@implementation ILBinding

@synthesize firstObject, secondObject;
@synthesize firstKey, secondKey;

@synthesize options;
@synthesize synchronizing;

- initBindingKey:(NSString*) key ofObject:(id) object toKey:(NSString*) otherKey ofObject:(id) otherObject options:(ILBindingOptions *)o;
{
    self = [super init];
    if (self) {
        self.firstObject = object;
        self.firstKey = key;
        self.secondObject = otherObject;
        self.secondKey = otherKey;
        
        self.options = o;
        
        [object addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
        [otherObject addObserver:self forKeyPath:otherKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void) dealloc;
{
    [self unbind];
    [super dealloc];
}

- (void) unbind;
{
    [self.firstObject removeObserver:self forKeyPath:self.firstKey];
    [self.secondObject removeObserver:self forKeyPath:self.secondKey];
}

static NSString* const kILBindingIsDispatchingChangeOnCurrentThreadKey = @"ILBindingIsDispatchingChangeOnCurrentThread";

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (self.options.concurrencyModel == kILBindingConcurrencyAllowedThread && self.options.allowedThread != [NSThread currentThread]) {
        
        [NSException raise:@"ILBindingDisallowedThreadException" format:@"This thread (%@) is not the allowed thread for this binding (%@). (This binding was set up with the allowed thread concurrency model.)", [NSThread currentThread], self.options.allowedThread];
        
    }
    
    if (self.synchronizing)
        return;
    
    self.synchronizing = YES;
    
    id otherObject = (object == self.firstObject ? self.secondObject : self.firstObject);
    NSString* otherKey = (object == self.firstObject ? self.secondKey : self.firstKey);
    
    [otherObject setValue:[object valueForKeyPath:keyPath] forKeyPath:otherKey];

    self.synchronizing = NO;
}

@end
