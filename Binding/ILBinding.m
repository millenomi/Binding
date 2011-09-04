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

- initWithKey:(NSString*) key ofSourceObject:(id) object boundToKey:(NSString*) otherKey ofTargetObject:(id) otherObject options:(ILBindingOptions *)o;
{
    self = [super init];
    if (self) {
        self.firstObject = object;
        self.firstKey = key;
        self.secondObject = otherObject;
        self.secondKey = otherKey;
        
        self.options = o;
        
        [object addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial context:NULL];
        [otherObject addObserver:self forKeyPath:otherKey options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
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
    ILBindingOptions* opts = self.options;
    
    if (opts.concurrencyModel == kILBindingConcurrencyAllowedThread && opts.allowedThread != [NSThread currentThread]) {
        
        [NSException raise:@"ILBindingDisallowedThreadException" format:@"This thread (%@) is not the allowed thread for this binding (%@). (This binding was set up with the allowed thread concurrency model.)", [NSThread currentThread], opts.allowedThread];
        
    }
    
    if (self.synchronizing)
        return;
    
    if (object == self.secondObject && opts.direction == kILBindingDirectionSourceToTargetOnly)
        return;
    
    self.synchronizing = YES;
    
    id otherObject = (object == self.firstObject ? self.secondObject : self.firstObject);
    NSString* otherKey = (object == self.firstObject ? self.secondKey : self.firstKey);
    
    NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    
    if (kind == NSKeyValueChangeSetting) {
        
        [otherObject setValue:[object valueForKeyPath:keyPath] forKeyPath:otherKey];
        
    } else {
        
        BOOL isRelationshipOrdered = [[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSArray class]] || [[change objectForKey:NSKeyValueChangeOldKey] isKindOfClass:[NSArray class]];
        
        if (isRelationshipOrdered) {
            
            switch (kind) {
                case NSKeyValueChangeInsertion: {
                    
                    NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                    NSArray* objects = [change objectForKey:NSKeyValueChangeNewKey];
                    
                    [[otherObject mutableArrayValueForKey:otherKey] insertObjects:objects atIndexes:indexes];
                    
                    break;
                }
                    
                case NSKeyValueChangeRemoval: {
                    
                    NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                    
                    [[otherObject mutableArrayValueForKey:otherKey] removeObjectsAtIndexes:indexes];
                    
                    break;
                }
                    
                case NSKeyValueChangeReplacement: {
                    
                    NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                    NSArray* objects = [change objectForKey:NSKeyValueChangeNewKey];
                    
                    [[otherObject mutableArrayValueForKey:otherKey] replaceObjectsAtIndexes:indexes withObjects:objects];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
        } else /* relationship is unordered */ {
            
            switch (kind) {
                case NSKeyValueChangeInsertion: {
                    
                    NSSet* objects = [change objectForKey:NSKeyValueChangeNewKey];
                    
                    [[otherObject mutableSetValueForKey:otherKey] unionSet:objects];
                    
                    break;
                }
                    
                case NSKeyValueChangeRemoval: {
                    
                    NSSet* objects = [change objectForKey:NSKeyValueChangeOldKey];
                    
                    [[otherObject mutableSetValueForKey:otherKey] minusSet:objects];
                    
                    break;
                }
                    
                case NSKeyValueChangeReplacement: {
                    
                    NSSet* addedObjects = [change objectForKey:NSKeyValueChangeNewKey];
                    NSSet* removedObjects = [change objectForKey:NSKeyValueChangeOldKey];
                    
                    NSMutableSet* mutableSet = [otherObject mutableSetValueForKey:otherKey];
                    [mutableSet minusSet:removedObjects];
                    [mutableSet unionSet:addedObjects];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
        }
        
    }
    
    self.synchronizing = NO;
}

@end
