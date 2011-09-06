//
//  ILBindingsSet.m
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingsSet.h"
#import "ILBindingDefinition.h"
#import "ILBindingDefinition+ILBindingsLoadingMany.h"

@interface ILBindingsSet ()
@property(copy, nonatomic) NSSet* allBindings;
@property(copy, nonatomic) NSDictionary* allBindingsByKey;
@end

@implementation ILBindingsSet

@synthesize allBindings, allBindingsByKey;

+ bindingsSetNamed:(NSString*) name owner:(id) owner; 
{
    return [self bindingsSetNamed:name bundle:[NSBundle bundleForClass:[owner class]] sourceObject:owner targetObject:owner];
}

+ bindingsSetNamed:(NSString*) name bundle:(NSBundle*) bundle sourceObject:(id) source targetObject:(id) target;
{
    return [[[self alloc] initWithResourceNamed:name withExtension:kILBindingDefinitionFileExtension bundle:bundle sourceObject:source targetObject:target error:NULL] autorelease];
}

- (id) initWithResourceNamed:(NSString*) resource withExtension:(NSString*) extension owner:(id) owner error:(NSError**) error;
{
    return [self initWithResourceNamed:resource withExtension:extension bundle:[NSBundle bundleForClass:[owner class]] sourceObject:owner targetObject:owner error:error];
}

- (id) initWithResourceNamed:(NSString*) resource withExtension:(NSString*) extension bundle:(NSBundle*) bundle sourceObject:(id) source targetObject:(id) target error:(NSError**) error;
{
    self = [super init];
    if (self) {
        
        NSDictionary* byKey;
        self.allBindings = [ILBindingDefinition definitionsInResourceNamed:resource withExtension:extension bundle:bundle definitionsByKey:&byKey error:error];
        
        if (!self.allBindings) {
            [self release];
            return nil;
        }
        
        self.allBindingsByKey = byKey;
        
    }
    
    return self;
}

- (void)dealloc;
{
    [self unbind];
    
    [allBindings release];
    [allBindingsByKey release];
    [super dealloc];
}

- (void)unbind;
{
    [self.allBindings makeObjectsPerformSelector:@selector(unbind)];
}

@end
