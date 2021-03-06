//
//  ILBinding.m
//  Binding
//
//  Created by ∞ on 03/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILBinding.h"

@interface ILBinding ()

// The roots of our binding chains.
@property(assign, nonatomic) id sourceObject, targetObject;

// The key paths.
@property(copy, nonatomic) NSString* sourceKeyPath, * targetKeyPath;

@property(copy, nonatomic) ILBindingOptions* options;
@property(nonatomic, getter = isSynchronizing) BOOL synchronizing;

- (void) synchronizeFromTargetToSource;

@property(retain, nonatomic) NSMutableSet* cleanupBlocks;
- (void) addCleanupBlock:(void(^)(ILBinding* myself)) block;

@end


@implementation ILBinding

@synthesize sourceObject, targetObject;
@synthesize sourceKeyPath, targetKeyPath;

@synthesize options;
@synthesize synchronizing;

@synthesize cleanupBlocks;

@synthesize logging;

+ bindingWithKeyPath:(NSString*) key ofSourceObject:(id) object boundToKeyPath:(NSString*) otherKey ofTargetObject:(id) otherObject options:(ILBindingOptions*) options;
{
    return [[[self alloc] initWithKeyPath:key ofSourceObject:object boundToKeyPath:otherKey ofTargetObject:otherObject options:options] autorelease];
}

- initWithKeyPath:(NSString*) sourcePath ofSourceObject:(id) source boundToKeyPath:(NSString*) targetPath ofTargetObject:(id) target options:(ILBindingOptions *)o;
{
    self = [super init];
    if (self) {        
        self.options = o ?: [ILBindingOptions optionsWithDefaultValues];
        
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
    for (void (^block)(ILBinding*) in self.cleanupBlocks)
        block(self);
    
    self.cleanupBlocks = nil;
    
    [self.sourceObject removeObserver:self forKeyPath:self.sourceKeyPath];
    [self.targetObject removeObserver:self forKeyPath:self.targetKeyPath];
    
    self.sourceObject = nil;
    self.targetObject = nil;
    
    self.sourceKeyPath = nil;
    self.targetKeyPath = nil;
}

- (void) addCleanupBlock:(void (^)(ILBinding*))block;
{
    if (!self.cleanupBlocks)
        self.cleanupBlocks = [NSMutableSet set];
    
    [self.cleanupBlocks addObject:[[block copy] autorelease]];
}

static NSString* const kILBindingIsDispatchingChangeOnCurrentThreadKey = @"ILBindingIsDispatchingChangeOnCurrentThread";

- (NSArray*) arrayByTransformingArray:(NSArray*) objects usingValueTransformerSelector:(SEL) sel;
{
    ILBindingOptions* opts = self.options;
    if (!opts.valueTransformer)
        return objects;
    
    NSMutableArray* transformedObjects = [NSMutableArray arrayWithCapacity:objects.count];
    for (id object in objects) {
        [transformedObjects addObject:[opts.valueTransformer performSelector:sel withObject:object]];
    }
    
    return transformedObjects;
}

- (NSSet*) setByTransformingSet:(NSSet*) objects usingValueTransformerSelector:(SEL) sel;
{
    ILBindingOptions* opts = self.options;
    if (!opts.valueTransformer)
        return objects;
    
    NSMutableSet* transformedObjects = [NSMutableSet setWithCapacity:objects.count];
    for (id object in objects) {
        [transformedObjects addObject:[opts.valueTransformer performSelector:sel withObject:object]];
    }
    
    return transformedObjects;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    ILBindingOptions* opts = self.options;
    
    if (opts.concurrencyModel == kILBindingConcurrencyAllowedThread && opts.allowedThread != [NSThread currentThread]) {
        
        [NSException raise:@"ILBindingDisallowedThreadException" format:@"This thread (%@) is not the allowed thread for this binding (%@). (This binding was set up with the allowed thread concurrency model.)", [NSThread currentThread], opts.allowedThread];
        
    }
    
    void (^performSync)() = ^{
        
        if (self.synchronizing)
            return;
        
        if (object == self.targetObject && [keyPath isEqualToString:self.targetKeyPath] && opts.direction == kILBindingDirectionSourceToTargetOnly)
            return;
        
        self.synchronizing = YES;
        
        id otherObject = (object == self.sourceObject && [keyPath isEqualToString:self.sourceKeyPath]? self.targetObject : self.sourceObject);
        NSString* otherKey = (object == self.sourceObject && [keyPath isEqualToString:self.sourceKeyPath]? self.targetKeyPath : self.sourceKeyPath);
        
        SEL valueTransformerSelector = (object == self.sourceObject? @selector(transformedValue:) : @selector(reverseTransformedValue:));
        
        NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        
        if (kind == NSKeyValueChangeSetting) {
            
            id value = [change objectForKey:NSKeyValueChangeNewKey];
            
            if (self.logging) {
                NSLog(@"%@ - Will change value for %@ -> %@ (from %@ -> %@) to\n\t%@", self, otherObject, otherKey, object, keyPath, value);
            }
            
            if (opts.valueTransformer) {
                value = [opts.valueTransformer performSelector:valueTransformerSelector withObject:value];
                
                if (self.logging)
                    NSLog(@"Value transformed to: %@", value);
            }
            
            [otherObject setValue:value forKeyPath:otherKey];
            
        } else {
            
            BOOL isRelationshipOrdered = [[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSArray class]] || [[change objectForKey:NSKeyValueChangeOldKey] isKindOfClass:[NSArray class]];
            
            if (isRelationshipOrdered) {
                
                switch (kind) {
                    case NSKeyValueChangeInsertion: {
                        
                        NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                        NSArray* objects = [change objectForKey:NSKeyValueChangeNewKey];
                        
                        if (self.logging) {
                            NSLog(@"%@ - Will change value for %@ -> %@ (from %@ -> %@)\n\tby inserting objects: %@\n\tat indexes: %@", self, otherObject, otherKey, object, keyPath, objects, indexes);
                        }
                        
                        objects = [self arrayByTransformingArray:objects usingValueTransformerSelector:valueTransformerSelector];
                        
                        [[otherObject mutableArrayValueForKey:otherKey] insertObjects:objects atIndexes:indexes];
                        
                        break;
                    }
                        
                    case NSKeyValueChangeRemoval: {
                        
                        NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                        
                        if (self.logging) {
                            NSLog(@"%@ - Will change value for %@ -> %@ (from %@ -> %@)\n\tby removing objects: %@\n\tfrom indexes: %@", self, otherObject, otherKey, object, keyPath, [change objectForKey:NSKeyValueChangeOldKey], indexes);
                        }
                        
                        [[otherObject mutableArrayValueForKey:otherKey] removeObjectsAtIndexes:indexes];
                        
                        break;
                    }
                        
                    case NSKeyValueChangeReplacement: {
                        
                        NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
                        NSArray* objects = [change objectForKey:NSKeyValueChangeNewKey];
                        
                        objects = [self arrayByTransformingArray:objects usingValueTransformerSelector:valueTransformerSelector];
                        
                        if (self.logging) {
                            NSLog(@"%@ - Will change value for %@ -> %@ (from %@ -> %@)\n\tby replacing objects: %@\n\tat indexes: %@\n\twith objects: %@", self, otherObject, otherKey, object, keyPath, [change objectForKey:NSKeyValueChangeOldKey], indexes, objects);
                        }
                        
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
                        
                        objects = [self setByTransformingSet:objects usingValueTransformerSelector:valueTransformerSelector];
                        
                        if (self.logging) {
                            NSLog(@"%@ - Will change value for %@ -> %@ (from %@ -> %@)\n\tby set union with objects: %@", self, otherObject, otherKey, object, keyPath, objects);
                        }
                        
                        [[otherObject mutableSetValueForKey:otherKey] unionSet:objects];
                        
                        break;
                    }
                        
                    case NSKeyValueChangeRemoval: {
                        
                        NSSet* objects = [change objectForKey:NSKeyValueChangeOldKey];
                        
                        objects = [self setByTransformingSet:objects usingValueTransformerSelector:valueTransformerSelector];
                        
                        if (self.logging) {
                            NSLog(@"%@ - Will change value for %@ -> %@ (from %@ -> %@)\n\tby set difference with objects: %@", self, otherObject, otherKey, object, keyPath, objects);
                        }
                        
                        [[otherObject mutableSetValueForKey:otherKey] minusSet:objects];
                        
                        break;
                    }
                        
                    case NSKeyValueChangeReplacement: {
                        
                        NSSet* addedObjects = [change objectForKey:NSKeyValueChangeNewKey];
                        NSSet* removedObjects = [change objectForKey:NSKeyValueChangeOldKey];
                        
                        addedObjects = [self setByTransformingSet:addedObjects usingValueTransformerSelector:valueTransformerSelector];
                        removedObjects = [self setByTransformingSet:removedObjects usingValueTransformerSelector:valueTransformerSelector];
                        
                        if (self.logging) {
                            NSLog(@"%@ - Will change value for %@ -> %@ (from %@ -> %@)\n\tby replacing set of objects: %@\n\twith objects: %@", self, otherObject, otherKey, object, keyPath, addedObjects, removedObjects);
                        }
                        
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
        
    };

    if (opts.concurrencyModel == kILBindingConcurrencyDispatchOnQueue)
        dispatch_async(opts.dispatchQueue, performSync);
    else
        performSync();
}

- (void) synchronizeFromTargetToSource;
{
    ILBindingOptions* opts = self.options;
    
    if (opts.concurrencyModel == kILBindingConcurrencyAllowedThread && opts.allowedThread != [NSThread currentThread]) {
        
        [NSException raise:@"ILBindingDisallowedThreadException" format:@"This thread (%@) is not the allowed thread for this binding (%@). (This binding was set up with the allowed thread concurrency model.)", [NSThread currentThread], opts.allowedThread];
        
    }    
    
    self.synchronizing = YES;
    
    [self.sourceObject setValue:[self.targetObject valueForKeyPath:self.targetKeyPath] forKeyPath:self.sourceKeyPath];
    
    self.synchronizing = NO;
}

- (ILBinding *)setLogging;
{
    self.logging = YES;
    return self;
}

@end


#if TARGET_OS_IPHONE

@implementation ILBinding (ILUIControlBindingAdditions)

- (id)initWithKeyPath:(NSString *)key ofSourceObject:(id)object boundToKeyPath:(NSString *)otherKey ofTargetUIControl:(UIControl*)otherObject options:(ILBindingOptions *)opts;
{
    NSAssert((opts.concurrencyModel == kILBindingConcurrencyAllowedThread && opts.allowedThread == [NSThread mainThread]) ||
             (opts.concurrencyModel == kILBindingConcurrencyDispatchOnQueue && opts.dispatchQueue == dispatch_get_main_queue()) , @"Binding to UIControl requires dispatch to occur on the main thread.");
    
    if (opts.direction == kILBindingDirectionSourceToTargetOnly) {
        return [self initWithKeyPath:key ofSourceObject:object boundToKeyPath:otherKey ofTargetObject:otherObject options:opts];
    }
    
    ILBindingOptions* actualOptions = [[opts copy] autorelease];
    actualOptions.direction = kILBindingDirectionSourceToTargetOnly;
    
    self = [self initWithKeyPath:key ofSourceObject:object boundToKeyPath:otherKey ofTargetObject:otherObject options:actualOptions];
    
    if (self) {
        [otherObject addTarget:self action:@selector(synchronizeFromTargetToSource) forControlEvents:UIControlEventValueChanged];
        
        [self addCleanupBlock:^(ILBinding* me) {
            [(UIControl*)me.targetObject removeTarget:self action:@selector(synchronizeFromTargetToSource) forControlEvents:UIControlEventValueChanged];
        }];
    }
    
    return self;
}

+ (id)bindingWithKeyPath:(NSString *)key ofSourceObject:(id)object boundToKeyPath:(NSString *)otherKey ofTargetUIControl:(UIControl*)otherObject options:(ILBindingOptions *)options;
{
    return [[[self alloc] initWithKeyPath:key ofSourceObject:object boundToKeyPath:otherKey ofTargetUIControl:otherObject options:options] autorelease];
}

@end

#endif
