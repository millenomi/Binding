//
//  ILBindingOptions.h
//  Binding
//
//  Created by ∞ on 04/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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


@interface ILBindingOptions : NSObject <NSCopying, NSMutableCopying>

+ optionsWithDefaultValues;
- (id)init;

@property(nonatomic) ILBindingConcurrencyModel concurrencyModel;
@property(nonatomic, retain) NSThread* allowedThread;

@property(nonatomic) ILBindingDirection direction;

@end
