//
//  ILBindingOptions.h
//  Binding
//
//  Created by ∞ on 04/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

// Explicit enum names for Doxygen.

/**
 This enumeration allows you to choose a concurrency model for the binding. The concurrency model defines how the binding behaves in the face of concurrent access on multiple threads.
 */
typedef enum {
    /**
     If this concurrency model is set, then changes on the allowed thread will be propagated without any coordination (dispatching or locking). Changes on threads other than the allowed thread will cause an exception to be thrown.
     
     This is the default concurrency model. The allowed thread can be set with the -[ILBindingOptions allowedThread] property; if not set, the main thread is the default.
     */
    kILBindingConcurrencyAllowedThread = 0,
} ILBindingConcurrencyModel;

/**
 This enumeration allows you to choose how changes to the target or source objects are propagated.
 */
typedef enum {
    /** Changes to the bound key on the source object are reflected on the corresponding key of the target object, and vice versa. This is the default. */
    kILBindingDirectionBoth = 0,
    
    /** Changes to the bound key on the source object are reflected on the corresponding key of the target object, but not the other way round. */
    kILBindingDirectionSourceToTargetOnly,
} ILBindingDirection;

/**
 Instances of this class represent the options for a binding (an ILBinding instance). You create one with the -init method (or the +optionsWithDefaultValues convenience method), then proceed to customize it.
 
 Note that this class has the property that, no matter what you set, it will try to keep its members consistent. For instance, setting an allowed thread automatically sets the concurrency model to kILBindingConcurrencyAllowedThread, and vice versa setting a different concurrency model means the allowedThread property is set to nil.
 
 Instances are copiable. All copies, whether made with -copy or -mutableCopy, are mutable.
 */
@interface ILBindingOptions : NSObject <NSCopying, NSMutableCopying>

/** Convenience method for -init. */
+ optionsWithDefaultValues;

/** Creates a binding options object with default values. For information on default values, see the individual properties */
- (id)init;

/** Sets the concurrency model of the binding. It specifies how the binding behaves in the face of concurrent access to the observed key paths.
 
 For more information, see the documentation for the ILBindingConcurrencyModel type. */
@property(nonatomic) ILBindingConcurrencyModel concurrencyModel;

/** If the concurrency model is set to kILBindingConcurrencyAllowedThread, then this property indicates which thread is allowed to perform changes to the observed keys for both the source and target objects. The default thread is the main thread.
 
 If any other concurrency model is set, this property will be set to nil. */
@property(nonatomic, retain) NSThread* allowedThread;

/** Sets the direction of the binding. The direction specifies how the data is propagated when changes occur.
 
 For more information, see the documentation for the ILBindingDirection type. */
@property(nonatomic) ILBindingDirection direction;

/** The value transformer for the binding.
 
 The transformer will be applied to values coming from the source object to produce values that will be provided to the target object; reverse transformation, if available, occurs in the other direction.
 
 If the transformer does not support reverse transformations, the direction will be set automatically to kILBindingDirectionSourceToTargetOnly.
 */
@property(nonatomic, retain) NSValueTransformer* valueTransformer;

@end
