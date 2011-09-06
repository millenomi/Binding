//
//  ILBindingDefinition+ILBindingsLoadingMany.m
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingDefinition+ILBindingsLoadingMany.h"

#define kILBindingDefinitionContainerKey @"ILBindings"

@implementation ILBindingDefinition (ILBindingsLoadingMany)

+ (NSSet*) definitionsInResourceNamed:(NSString*) resource withExtension:(NSString*) extension bundle:(NSBundle*) bundle definitionsByKey:(NSDictionary**) byKey error:(NSError**) error;
{
    if (!bundle)
        bundle = [NSBundle mainBundle];
    
    NSURL* url = [bundle URLForResource:resource withExtension:extension];
    if (!url) {
        if (error) *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorInvalidPropertyList userInfo:nil];
        return nil;
    }
    
    NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfURL:url];
    if (!dictionary){
        if (error) *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorInvalidPropertyList userInfo:nil];
        return nil;
    }
    
    id allDefinitionPlists = [dictionary objectForKey:kILBindingDefinitionContainerKey];
    if (!allDefinitionPlists || ![allDefinitionPlists isKindOfClass:[NSArray class]]){
        if (error) *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorInvalidPropertyList userInfo:nil];
        return nil;
    }
    
    NSMutableSet* result = [NSMutableSet set];
    NSMutableDictionary* resultsByKey = nil;
    if (byKey)
        resultsByKey = [NSMutableDictionary dictionary];
    
    for (id plist in allDefinitionPlists) {
        ILBindingDefinition* definition = [[[ILBindingDefinition alloc] initWithPropertyListRepresentation:plist error:error] autorelease];
        
        if (!definition)
            return nil;
        
        if (definition.key && ![definition.key isEqualToString:@""]) {
            if ([resultsByKey objectForKey:definition.key]) {
                if (error) {
                    NSDictionary* info = [NSDictionary dictionaryWithObject:definition.key forKey:kILBindingDefinitionErrorSourceKey];
                    *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorDuplicateKey userInfo:info];                  
                    return nil;
                }
            }
            
            [resultsByKey setObject:definition forKey:definition.key];
        }
    }
    
    if (byKey)
        *byKey = resultsByKey;
    return result;
}

@end
