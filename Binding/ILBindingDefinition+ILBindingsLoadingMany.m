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

    return [self definitionsWithContentsOfURL:url options:0 definitionsByKey:byKey error:error];
}

+ (NSData*) propertyListDataWithDefinitions:(NSSet*) definitions error:(NSError**) error;
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSMutableArray* definitionPlists = [NSMutableArray arrayWithCapacity:definitions.count];
    
    for (ILBindingDefinition* definition in definitions)
        [definitionPlists addObject:definition.propertyListRepresentation];
    
    [dictionary setObject:definitionPlists forKey:kILBindingDefinitionContainerKey];
    
    return [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:error];
}

+ (BOOL) writeDefinitions:(NSSet*) definitions toFileAtURL:(NSURL*) url error:(NSError**) error;
{
    NSData* data = [self propertyListDataWithDefinitions:definitions error:error];
    if (!data)
        return NO;
        
    return [data writeToURL:url options:NSDataWritingAtomic error:error];
}

+ (NSSet*) definitionsWithContentsOfURL:(NSURL*) url options:(ILBindingLoadingManyOptions) opts  definitionsByKey:(NSDictionary**) byKey error:(NSError**) error;
{
    return [self definitionsWithPropertyListData:[NSData dataWithContentsOfURL:url] options:opts definitionsByKey:byKey error:error];
}

+ (NSSet*) definitionsWithPropertyListData:(NSData*) data options:(ILBindingLoadingManyOptions) opts definitionsByKey:(NSDictionary**) byKey error:(NSError**) error;
{
    id plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:error];
    if (!plist)
        return nil;
    
    if (![plist isKindOfClass:[NSDictionary class]]) {
        if (error) *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorInvalidPropertyList userInfo:nil];
        return nil;
    }
    
    id allDefinitionPlists = [plist objectForKey:kILBindingDefinitionContainerKey];
    if (!allDefinitionPlists || ![allDefinitionPlists isKindOfClass:[NSArray class]]){
        if (error) *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorInvalidPropertyList userInfo:nil];
        return nil;
    }
    
    NSMutableSet* result = [NSMutableSet set];
    NSMutableDictionary* resultsByKey = nil;
    if (byKey)
        resultsByKey = [NSMutableDictionary dictionary];
    
    for (id plist in allDefinitionPlists) {
        ILBindingLoadingOptions singleOptions = 0;
        if (opts & kILBindingLoadingAllowIncompleteOrDuplicateDefinitions)
            singleOptions |= kILBindingLoadingAllowIncompletePropertyList;
        
        ILBindingDefinition* definition = [[[ILBindingDefinition alloc] initWithPropertyListRepresentation:plist options:singleOptions error:error] autorelease];
        
        if (!definition)
            return nil;
        
        [result addObject:definition];
        
        if (definition.key && ![definition.key isEqualToString:@""]) {
            if ((opts & kILBindingLoadingAllowIncompleteOrDuplicateDefinitions) == 0 && [resultsByKey objectForKey:definition.key]) {
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
