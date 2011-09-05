//
//  ILBinding.m
//  Binding
//
//  Created by ∞ on 03/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBinding.h"

@interface ILBinding ()

// The roots of our binding chains.
@property(assign, nonatomic) id sourceObject, targetObject;

// The key paths.
@property(copy, nonatomic) NSString* sourceKeyPath, * targetKeyPath;

@property(copy, nonatomic) ILBindingOptions* options;
@property(nonatomic, getter = isSynchronizing) BOOL synchronizing;

@end


@implementation ILBinding

@synthesize sourceObject, targetObject;
@synthesize sourceKeyPath, targetKeyPath;

@synthesize options;
@synthesize synchronizing;

- initWithKeyPath:(NSString*) sourcePath ofSourceObject:(id) source boundToKeyPath:(NSString*) targetPath ofTargetObject:(id) target options:(ILBindingOptions *)o;
{
    self = [super init];
    if (self) {        
        self.options = o;
        
        self.sourceObject = source;
        self.sourceKeyPath = sourcePath;
        self.targetObject = target;
        self.targetKeyPath = targetPath;
        
        [self.targetObject addObserver:self forKeyPath:self.targetKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        [self.sourceObject addObserver:self forKeyPath:self.sourceKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial context:NULL];
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
    [self.sourceObject removeObserver:self forKeyPath:self.sourceKeyPath];
    [self.targetObject removeObserver:self forKeyPath:self.targetKeyPath];
    
    self.sourceObject = nil;
    self.targetObject = nil;
    
    self.sourceKeyPath = nil;
    self.targetKeyPath = nil;
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
    
    if (object == self.targetObject && opts.direction == kILBindingDirectionSourceToTargetOnly)
        return;
    
    self.synchronizing = YES;
    
    id otherObject = (object == self.sourceObject ? self.targetObject : self.sourceObject);
    NSString* otherKey = (object == self.sourceObject ? self.targetKeyPath : self.sourceKeyPath);
    
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
