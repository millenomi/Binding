//
//  ILBindingDefinition.h
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILBinding.h"
#import "ILBindingOptions.h"

typedef enum {
    kILBindingLoadingAllowIncompletePropertyList = 1 << 0,
} ILBindingLoadingOptions;

@interface ILBindingDefinition : NSObject <NSCopying, NSMutableCopying>

// Loading a definition from a plist
- (id) initWithPropertyListRepresentation:(id) plist options:(ILBindingLoadingOptions) options error:(NSError**) error;

// Creating a definition from scratch (eg for saving via propertyListRepresentation)
- (id) initWithPathToSource:(NSString*) pts boundSourceKeyPath:(NSString*) sourcePath pathToTarget:(NSString*) ptt boundTargetKeyPath:(NSString*) targetKeyPath options:(ILBindingOptions*) options key:(NSString*) optionalKey;

- (ILBinding*) bindingWithOwner:(id) owner options:(ILBindingOptions*) opts;
- (ILBinding*) bindingWithSourceObject:(id) source targetObject:(id) target options:(ILBindingOptions*) opts;

@property(readonly, nonatomic) id propertyListRepresentation;

@property(readonly, copy, nonatomic) NSString* key;

@end


#define kILBindingDefinitionErrorDomain @"net.infinite-labs.ILBinding.Definition"
enum {
    kILBindingDefinitionErrorInvalidPropertyList = 1,
    kILBindingDefinitionErrorMissingEntry,
    kILBindingDefinitionErrorInvalidEntry,
    kILBindingDefinitionErrorDuplicateKey,
};

#define kILBindingDefinitionErrorSourceKey @"ILBindingDefinitionErrorSourceKey"
#define kILBindingDefinitionErrorSourceValue @"ILBindingDefinitionErrorSourceValue"


@interface ILMutableBindingDefinition : ILBindingDefinition

+ (NSSet*) allObservableKeys;

@property(copy, nonatomic) NSString* key;

@property(copy, nonatomic) NSString* pathToSource, * pathToTarget;
@property(copy, nonatomic) NSString* sourceKeyPath, * targetKeyPath;
@property(nonatomic) ILBindingDirection direction;
@property(copy, nonatomic) NSString* valueTransformerName;

@end