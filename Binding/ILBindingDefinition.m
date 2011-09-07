//
//  ILBindingDefinition.m
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingDefinition.h"

// This key uniquely identifies the binding within a set of bindings. Optional.
#define kILBindingDefinitionKey @"Key"

// These are the keys we must ask for from the owner object to get the source and target. Optional, default to self.
#define kILBindingDefinitionPathToSourceKey @"PathToSource"
#define kILBindingDefinitionPathToTargetKey @"PathToTarget"

// These are the key paths we actually bind to.
#define kILBindingDefinitionSourceKeyPathKey @"SourceKeyPath"
#define kILBindingDefinitionTargetKeyPathKey @"TargetKeyPath"

// -----
#define kILBindingDefinitionDirectionKey @"Direction"

#define kILBindingDefinitionDirectionBoth [NSNumber numberWithUnsignedInteger:kILBindingDirectionBoth]
#define kILBindingDefinitionDirectionSourceToTarget [NSNumber numberWithUnsignedInteger:kILBindingDirectionSourceToTargetOnly]

#define kILBindingDefinitionDirectionAllowableValues [NSSet setWithObjects:kILBindingDefinitionDirectionBoth, kILBindingDefinitionDirectionSourceToTarget, nil]
// -----

#define kILBindingDefinitionValueTransformerNameKey @"ValueTransformerName"


@interface ILBindingDefinition ()
@property(copy, nonatomic) NSString* key;

@property(copy, nonatomic) NSString* pathToSource, * pathToTarget;
@property(copy, nonatomic) NSString* sourceKeyPath, * targetKeyPath;
@property(nonatomic) ILBindingDirection direction;
@property(copy, nonatomic) NSString* valueTransformerName;

- (id) objectForKey:(NSString*) key inDictionary:(NSDictionary*) dict assumingOfClass:(Class) cls allowableValues:(NSSet*) allowable error:(NSError**) error;

- (id) copyWithClass:(Class) cls;

@end


@implementation ILBindingDefinition

@synthesize key;
@synthesize pathToSource, pathToTarget;
@synthesize sourceKeyPath, targetKeyPath;
@synthesize direction;
@synthesize valueTransformerName;

- (id) initWithPropertyListRepresentation:(id) plist options:(ILBindingLoadingOptions) options error:(NSError**) error;
{
    self = [super init];
    if (self) {
        if (![plist isKindOfClass:[NSDictionary class]]) {
            if (error) *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorInvalidPropertyList userInfo:nil];
            
            [self release];
            return nil;
        }
        
        BOOL validates = (options & kILBindingLoadingAllowIncompletePropertyList) == 0;
        
#define ILBindingDefinitionSetOrReturnError(what, key, valueClass, allowable) \
    what = [self objectForKey:key inDictionary:plist assumingOfClass:valueClass allowableValues:allowable error:error]; \
    if (validates && !what) { [self release]; return nil; }
        
        // --------------------
        // Required stuff
                
        ILBindingDefinitionSetOrReturnError(self.sourceKeyPath, kILBindingDefinitionSourceKeyPathKey, [NSString class], nil);
        ILBindingDefinitionSetOrReturnError(self.targetKeyPath, kILBindingDefinitionTargetKeyPathKey, [NSString class], nil);
        
        NSNumber* directionNumber;
        ILBindingDefinitionSetOrReturnError(directionNumber, kILBindingDefinitionDirectionKey, [NSNumber class], kILBindingDefinitionDirectionAllowableValues);
        self.direction = [directionNumber unsignedIntegerValue];
        
        // --------------------
        // Optional stuff
        
        // Value transformer name
        
        NSError* optionalError;
        
#define ILBindingDefinitionSetOptionallyOrReturnError(what, key, valueClass, allowable) \
    what = [self objectForKey:key inDictionary:plist assumingOfClass:valueClass allowableValues:allowable error:&optionalError]; \
    if (!what && !([[optionalError domain] isEqualToString:kILBindingDefinitionErrorDomain] && [optionalError code] == kILBindingDefinitionErrorMissingEntry)) { \
            if (error) *error = optionalError; \
            [self release]; return nil; \
    }
        
        // Value transformer name
        
        ILBindingDefinitionSetOptionallyOrReturnError(self.valueTransformerName, kILBindingDefinitionValueTransformerNameKey, [NSString class], nil);
        
        if ([self.valueTransformerName isEqualToString:@""])
            self.valueTransformerName = nil;
        
        // Identifier
        
        ILBindingDefinitionSetOptionallyOrReturnError(self.key, kILBindingDefinitionKey, [NSString class], nil);
        
        if ([self.key isEqualToString:@""])
            self.key = nil;
        
        // Paths to source and target
        
        ILBindingDefinitionSetOptionallyOrReturnError(self.pathToSource, kILBindingDefinitionPathToSourceKey, [NSString class], nil);
        
        if ([self.pathToSource isEqualToString:@""])
            self.key = nil;
        
        ILBindingDefinitionSetOptionallyOrReturnError(self.pathToTarget, kILBindingDefinitionPathToTargetKey, [NSString class], nil);
        
        if ([self.pathToTarget isEqualToString:@""])
            self.pathToTarget = nil;
        
        
#undef ILBindingDefinitionSetOptionallyOrReturnError
#undef ILBindingDefinitionSetOrReturnError
        
    }
    
    return self;
}

- (id) initWithPathToSource:(NSString*) pts boundSourceKeyPath:(NSString*) sp pathToTarget:(NSString*) ptt boundTargetKeyPath:(NSString*) tp options:(ILBindingOptions*) opts key:(NSString*) optionalKey;
{
    self = [super init];
    if (self) {
        self.key = optionalKey;
        
        self.pathToSource = pts;
        self.pathToTarget = ptt;
        
        self.sourceKeyPath = sp;
        self.targetKeyPath = tp;
        
        self.direction = opts.direction;
        
        if (opts.valueTransformer) {
            for (NSString* name in [NSValueTransformer valueTransformerNames]) {
                if ([NSValueTransformer valueTransformerForName:name] == opts.valueTransformer) {
                    self.valueTransformerName = name;
                }
            }
            
            if (!self.valueTransformerName)
                self.valueTransformerName = NSStringFromClass([opts.valueTransformer class]);
        }
    }
    
    return self;
}

- (void) dealloc;
{
    [key release];
    [pathToSource release];
    [pathToTarget release];
    [sourceKeyPath release];
    [targetKeyPath release];
    [valueTransformerName release];
     
    [super dealloc];
}

- (id) objectForKey:(NSString*) aKey inDictionary:(NSDictionary*) dict assumingOfClass:(Class) cls allowableValues:(NSSet*) allowable error:(NSError**) error;
{
    id value = [dict objectForKey:aKey];
    
    if (!value) {
        if (error) {
            NSDictionary* dict = [NSDictionary dictionaryWithObject:aKey forKey:kILBindingDefinitionErrorSourceKey];
            
            *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorMissingEntry userInfo:dict];
        }
        
        return nil;
    } else if (![value isKindOfClass:cls] || (allowable && ![allowable containsObject:value])) {
        if (error) {
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  aKey, kILBindingDefinitionErrorSourceKey,
                                  value, kILBindingDefinitionErrorSourceValue,
                                  nil];
            
            *error = [NSError errorWithDomain:kILBindingDefinitionErrorDomain code:kILBindingDefinitionErrorInvalidEntry userInfo:dict];
        }
        
        return nil;
    }
    
    return value;
}

- (id)propertyListRepresentation;
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];

    if (self.pathToSource)
        [dictionary setObject:self.pathToSource forKey:kILBindingDefinitionPathToSourceKey];
    
    if (self.pathToTarget)
        [dictionary setObject:self.pathToTarget forKey:kILBindingDefinitionPathToTargetKey];
    
    if (self.sourceKeyPath)
        [dictionary setObject:self.sourceKeyPath forKey:kILBindingDefinitionSourceKeyPathKey];
    
    if (self.targetKeyPath)
        [dictionary setObject:self.targetKeyPath forKey:kILBindingDefinitionTargetKeyPathKey];
    
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.direction] forKey:kILBindingDefinitionDirectionKey];
    
    if (self.valueTransformerName)
        [dictionary setObject:self.valueTransformerName forKey:kILBindingDefinitionValueTransformerNameKey];
    
    if (self.key)
        [dictionary setObject:self.key forKey:kILBindingDefinitionKey];
    
    return dictionary;
}

- (ILBinding*) bindingWithOwner:(id) owner options:(ILBindingOptions*) opts;
{
    return [self bindingWithSourceObject:owner targetObject:owner options:opts];
}

- (ILBinding*) bindingWithSourceObject:(id) source targetObject:(id) target options:(ILBindingOptions*) opts;
{
    if (opts)
        opts = [[opts copy] autorelease];
    else
        opts = [ILBindingOptions optionsWithDefaultValues];
    
    opts.direction = self.direction;
    if (self.valueTransformerName) {
        opts.valueTransformer = [NSValueTransformer valueTransformerForName:self.valueTransformerName];
    }
    
    if (self.pathToSource)
        source = [source valueForKeyPath:self.pathToSource];
    
    if (self.pathToTarget)
        target = [target valueForKeyPath:self.pathToTarget];
    
#if TARGET_OS_IPHONE
    if ([target isKindOfClass:[UIControl class]]) {
        return [ILBinding bindingWithKeyPath:self.sourceKeyPath ofSourceObject:source boundToKeyPath:self.targetKeyPath ofTargetUIControl:target options:opts];
    }
#endif
    
    return [ILBinding bindingWithKeyPath:self.sourceKeyPath ofSourceObject:source boundToKeyPath:self.targetKeyPath ofTargetObject:target options:opts];
}

- (id) copyWithClass:(Class) cls;
{
    ILBindingOptions* opts = [ILBindingOptions optionsWithDefaultValues];
    opts.direction = self.direction;
    
    if (self.valueTransformerName)
        opts.valueTransformer = [NSValueTransformer valueTransformerForName:self.valueTransformerName];
    
    return [[cls alloc] initWithPathToSource:self.pathToSource boundSourceKeyPath:self.sourceKeyPath pathToTarget:self.pathToTarget boundTargetKeyPath:self.targetKeyPath options:opts key:self.key];
}

- (id)copyWithZone:(NSZone *)zone;
{
    return [self copyWithClass:[ILBindingDefinition class]];
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
    return [self copyWithClass:[ILMutableBindingDefinition class]];    
}

@end


@implementation ILMutableBindingDefinition

#define ILBindingDefinitionCallSuperForProperty(getter, setter, type) \
    - (type) getter { return [super getter]; } \
    - (void) setter (type) newValue { [super setter newValue]; }

ILBindingDefinitionCallSuperForProperty(key, setKey:, NSString*)
ILBindingDefinitionCallSuperForProperty(pathToSource, setPathToSource:, NSString*)
ILBindingDefinitionCallSuperForProperty(pathToTarget, setPathToTarget:, NSString*)
ILBindingDefinitionCallSuperForProperty(sourceKeyPath, setSourceKeyPath:, NSString*)
ILBindingDefinitionCallSuperForProperty(targetKeyPath, setTargetKeyPath:, NSString*)
ILBindingDefinitionCallSuperForProperty(direction, setDirection:, ILBindingDirection)
ILBindingDefinitionCallSuperForProperty(valueTransformerName, setValueTransformerName:, NSString*)

@end
