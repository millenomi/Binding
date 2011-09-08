//
//  ILBinding.h
//  Binding
//
//  Created by ∞ on 03/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILBindingOptions.h"

/**
 A ILBinding instance (or just a binding) synchronizes the value of a key path between two given objects, allowing changes to a model object to alter a controller or view object automatically (and vice versa).
 
 This synchronization typically has a change in either key path be reflected on the other, but there are several options that can be used to alter the final result. For more information, see the ILBindingOptions class.
 
 Once created, a binding will synchronize the value until the unbind message is sent. Just like KVO observer methods and the corresponding technology on Mac OS X, bindings do not retain either object; you must call unbind yourself before either of these objects becomes invalid. Once unbound, a binding object is of no further use.
 
 Although this class allows you to create a binding programmatically, you will typically create bindings through the Bindings Editor included with this library, and load them at runtime with the ILBindingsSet class. See that class's documentation for more information.
 */
@interface ILBinding : NSObject

/**
 Creates a new binding synchronizing the given key paths. 
 
 One of the objects is labeled as a 'source' object, and the other as a 'target' object. Once you create a bindings object, the value of the target object's key path is overwritten with the current value of the source object's key path.
 
 Typically, you will pass the model object as the 'source' object, and the controller or view object as the 'target' object. Many options assume this is the case. For more information, see the ILBindingOptions class.
 
 @warning Currently, having two different bindings to the same key paths of the same objects existing at the same time anywhere in your application will produce undefined behavior. Make sure they don't.
 
 @param key The key path of the source object to bind.
 @param object The source object to bind.
 @param otherKey The key path of the target object to bind.
 @param otherObject The target object to bind. The value of its key path will be overwritten as part of invoking this method with the value of the source object's key path.
 @param options The options to this binding. For a discussion of how they affect the binding, see the ILBindingOptions class documentation.
 
 */
- (id) initWithKeyPath:(NSString*) key ofSourceObject:(id) object boundToKeyPath:(NSString*) otherKey ofTargetObject:(id) otherObject options:(ILBindingOptions*) options;

/**
 Ends the effects of this binding object.
 
 After this method is called, the binding will not perform any further operation and will not reference the source and target objects any further; they can be safely released.
 
 This method can be invoked multiple times on the same binding. It will have no effect after the first invocation.
 */
- (void) unbind;

/** Convenience method for initWithKeyPath:ofSourceObject:boundToKeyPath:ofTargetObject:options:. See that method for more details. */
+ (id) bindingWithKeyPath:(NSString*) key ofSourceObject:(id) object boundToKeyPath:(NSString*) otherKey ofTargetObject:(id) otherObject options:(ILBindingOptions*) options;

/** Sets whether the binding logs all changes observed and all operations it performs. This can be useful for debugging.
 
 @see setLogging
 */
@property(nonatomic, getter = isLogging) BOOL logging;

/** Causes the binding to log all changes observed and all operations it performs. Returns the receiver.
 
 Invoking this method is equivalent to setting the logging property to YES; it's provided as a convenience, so that it can be chained with a constructor method.
 
 @return Returns the receiver.
 @see logging
 */
- (ILBinding*) setLogging;

@end


#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

/**
 This category adds support for observing the change of the value of UIControl objects, which is not handled using regular key-value observing facilities.
 
 There are limitations to using this method:
 
 * The UIControl must be the target object;
 * No support is given for UIControls that may appear through the key paths you provide; only the UIControl provided as the target object will be successfully observed.
 */
@interface ILBinding (ILUIControlBindingAdditions)

/** This method creates a binding that will synchronize the value whenever the value of the provided control changes (that is, every time the control sends a UIControlEventValueChanged event).
 
 For more information on the values of the parameters to pass to this method, see initWithKeyPath:ofSourceObject:boundToKeyPath:ofTargetObject:options:.
 */
- (id)initWithKeyPath:(NSString *)key ofSourceObject:(id)object boundToKeyPath:(NSString *)otherKey ofTargetUIControl:(UIControl*)otherObject options:(ILBindingOptions *)options;

/** Convenience method for initWithKeyPath:ofSourceObject:boundToKeyPath:ofTargetUIControl:options:. See that method's documentation for details. */
+ (id)bindingWithKeyPath:(NSString *)key ofSourceObject:(id)object boundToKeyPath:(NSString *)otherKey ofTargetUIControl:(UIControl*)otherObject options:(ILBindingOptions *)options;

@end

#endif
