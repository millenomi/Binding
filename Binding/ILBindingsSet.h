//
//  ILBindingsSet.h
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILBinding.h"

/** A bindings set represents a collection of bindings objects (that is, ILBinding instances) which are managed as a single unit. Typically, you create instances of this class to load a Bindings Editor resource file.
 */
@interface ILBindingsSet : NSObject

/** Returns a bindings set loaded from the given Bindings Editor file. The file is searched in the main bundle and bindings will be instantiated from the definitions therein.
 
 @param name The name of the resource file to load definitions from. Do not add an extension to the name.
 @param owner The object that will provide sources and targets for all bindings in the set.
 */
+ bindingsSetNamed:(NSString*) name owner:(id) owner;

/**
 Returns a binding object from the set that is identified by the provided key.
 
 Note that keys are optional in binding definitions. Binding definitions without keys cannot be returned by this method.
 */
- (ILBinding*) bindingForKey:(NSString*) identifier;

/** Causes all contained bindings to stop having effect. This invokes the unbind method on all ILBindings contained by this set. */
- (void) unbind;


+ bindingsSetNamed:(NSString*) name bundle:(NSBundle*) bundle sourceObject:(id) source targetObject:(id) target;

- (id) initWithResourceNamed:(NSString*) resource withExtension:(NSString*) extension owner:(id) owner error:(NSError**) error;
- (id) initWithResourceNamed:(NSString*) resource withExtension:(NSString*) extension bundle:(NSBundle*) bundle sourceObject:(id) source targetObject:(id) target error:(NSError**) error;

@end
