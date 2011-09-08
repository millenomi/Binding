//
//  ILBindingsSet.h
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILBinding.h"

@interface ILBindingsSet : NSObject

+ bindingsSetNamed:(NSString*) name owner:(id) owner;
- (ILBinding*) bindingForKey:(NSString*) identifier;
- (void) unbind;


+ bindingsSetNamed:(NSString*) name bundle:(NSBundle*) bundle sourceObject:(id) source targetObject:(id) target;

- (id) initWithResourceNamed:(NSString*) resource withExtension:(NSString*) extension owner:(id) owner error:(NSError**) error;
- (id) initWithResourceNamed:(NSString*) resource withExtension:(NSString*) extension bundle:(NSBundle*) bundle sourceObject:(id) source targetObject:(id) target error:(NSError**) error;

@end
