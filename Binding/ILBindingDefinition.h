//
//  ILBindingDefinition.h
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILBinding.h"
#import "ILBindingOptions.h"

/** This enumeration includes options you can set when creating a @ref ILBindingDefinition from a property list representation to modify loading behavior. */
typedef enum {
    /**
     This option, if set, allows loading a property list representation even if it was produced by an incomplete definition. Loading from incomplete property lists without this option results in an error being reported.
     */
    kILBindingLoadingAllowIncompletePropertyList = 1 << 0,
} ILBindingLoadingOptions;

/**
 A binding definition describes how a binding should be built in a way that can be saved and loaded persistently. The Bindings Editor produces data for objects of this kind that can be then loaded at runtime.
 
 Binding definitions can produce property list representations of themselves, and produce new copies of themselves by reading the data in this representation. See the @ref propertyListRepresentation and @ref initWithPropertyListRepresentation:options:error: methods for details.
 
 Definitions of this class are immutable and opaque. You can create mutable copies of the ILMutableBindingDefinition class for editing.
 */
@interface ILBindingDefinition : NSObject <NSCopying, NSMutableCopying>

/**
 Creates the binding definition from a property list representation. If loading is successful, a ILBindingDefinition instance is returned; otherwise, nil is returned and the error returned by reference through the error pointer, if not NULL.
 */
- (id) initWithPropertyListRepresentation:(id) plist options:(ILBindingLoadingOptions) options error:(NSError**) error;

/**
 Creates a binding from this definition. This is a convenience method for the @ref bindingWithSourceObject:targetObject:options: method when the source and target objects coincide. */
- (ILBinding*) bindingWithOwner:(id) owner options:(ILBindingOptions*) opts;

/**
 Creates a binding from this definition.
 
 @param source The source object. If the definition contains a path to the source, this object will be queried for the value of that path, then that new value will become the source object for the binding.
 @param target The target object. If the definition contains a path to the target, this object will be queried for the value of that path, then that new value will become the target object for the binding.
 @param opts The options for this binding. The binding will use the values in this options object for all options not specified by the definition. You can pass nil to use default values instead.
 */
- (ILBinding*) bindingWithSourceObject:(id) source targetObject:(id) target options:(ILBindingOptions*) opts;

/**
 Returns a property list representation of this object. This representation can be serialized or transmitted.
 
 It is not guaranteed that this object be anything in particular. It is however guaranteed that this object can be used as a root for a property list by itself (so it's either an array or dictionary).
 
 Note that a property list representation may be produced with incomplete information if this definition doesn't specify that. Loading an incomplete property list representation may fail.
 */
@property(readonly, nonatomic) id propertyListRepresentation;

/**
 Returns the key for this binding. A binding can be associated with a key, so that it can be uniquely identified among a set of loaded bindings.
 */
@property(readonly, copy, nonatomic) NSString* key;

@end

/** This is the error domain of errors that can occur while loading one or more definitions from their property list representations. */
#define kILBindingDefinitionErrorDomain @"net.infinite-labs.ILBinding.Definition"

/** These are the error codes for the @ref kILBindingDefinitionErrorDomain error domain. */
enum ILBindingDefinitionErrors {
    /** The property list passed in was not valid; it was not a property list, or it was not structured the way ILBindingDefinition expected it to be. */
    kILBindingDefinitionErrorInvalidPropertyList = 1,
    
    /** A dictionary within the property list had a missing entry. The key is provided in the user info's @ref kILBindingDefinitionErrorSourceKey key. */
    kILBindingDefinitionErrorMissingEntry,
    
    /** A dictionary within the property list had an invalid value for an entry. The key is provided in the user info's @ref kILBindingDefinitionErrorSourceKey key, and the invalid value is provided in the user info's @ref kILBindingDefinitionErrorSourceValue key. */    
    kILBindingDefinitionErrorInvalidEntry,
    
    /** When loading multiple definitions together, two or more of those had the same key. Definitions in the same set must have distinct keys. */
    kILBindingDefinitionErrorDuplicateKey,
};

/** Error user info key. The key that produced a kILBindingDefinitionErrorDomain error. */
#define kILBindingDefinitionErrorSourceKey @"ILBindingDefinitionErrorSourceKey"
/** Error user info key. The value that produced a kILBindingDefinitionErrorDomain error. */
#define kILBindingDefinitionErrorSourceValue @"ILBindingDefinitionErrorSourceValue"

/**
 This represents an editable binding definition. See the ILBindingDefinition class for details.
 */
@interface ILMutableBindingDefinition : ILBindingDefinition

/**
 Returrns all the keys that you should observe during editing. None of those keys are to-many relationships.
 */
+ (NSSet*) allObservableKeys;

/** Creates a mutable binding definition with no information. */
- (id) init;

/** The identifier for this definition. */
@property(copy, nonatomic) NSString* key;

@property(copy, nonatomic) NSString* pathToSource, * pathToTarget;
@property(copy, nonatomic) NSString* sourceKeyPath, * targetKeyPath;
@property(nonatomic) ILBindingDirection direction;
@property(copy, nonatomic) NSString* valueTransformerName;

@end