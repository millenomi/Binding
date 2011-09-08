//
//  ILBindingOptions.h
//  Binding
//
//  Created by ∞ on 04/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    /*
     If this model is used, then changes on the allowed thread will be propagated without any coordination (dispatching or locking). Changes on threads other than the allowed thread will cause an exception to be thrown.
     
     This is the default concurrency model. The allowed thread can be set with the .allowedThread property; if not set, the main thread is the default.
     */
    kILBindingConcurrencyAllowedThread,
} ILBindingConcurrencyModel;

typedef enum {
    /* Changes to the bound key on the source object are reflected on the corresponding key of the target object, and vice versa. This is the default. */
    kILBindingDirectionBoth,
    
    /* Changes to the bound key on the source object are reflected on the corresponding key of the target object, but not the other way round. */
    kILBindingDirectionSourceToTargetOnly,
} ILBindingDirection;

/*
 
 Instances of this class set up the options for a binding (an ILBinding instance). You create one with -init (or the +optionsWithDefaultValues convenience method), then proceed to customize it.
 
 Note that this class has the property that, no matter what you set, it will try to keep its members consistent. For instance, setting an allowed thread automatically sets the concurrency model to kILBindingConcurrencyAllowedThread, and vice versa setting a different concurrency model means the allowedThread property is set to nil.
 
 Instances are copiable. All copies, whether made with -copy or -mutableCopy, are mutable.
 
 */
@interface ILBindingOptions : NSObject <NSCopying, NSMutableCopying>

+ optionsWithDefaultValues;
- (id)init;

@property(nonatomic) ILBindingConcurrencyModel concurrencyModel;
@property(nonatomic, retain) NSThread* allowedThread;

@property(nonatomic) ILBindingDirection direction;

// The value transformer for the binding. Note that setting a one-way transformer sets the .direction to kILBindingDirectionSourceToTargetOnly.
@property(nonatomic, retain) NSValueTransformer* valueTransformer;

@end
