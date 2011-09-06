//
//  ILBindingDefinition+ILBindingsLoadingMany.h
//  Binding
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingDefinition.h"


#define kILBindingDefinitionFileExtension @"ilabs-bindings"

@interface ILBindingDefinition (ILBindingsLoadingMany)

+ (NSSet*) definitionsInResourceNamed:(NSString*) resource withExtension:(NSString*) extension bundle:(NSBundle*) bundle definitionsByKey:(NSDictionary**) byKey error:(NSError**) error;

+ (NSSet*) definitionsWithContentsOfURL:(NSURL*) url definitionsByKey:(NSDictionary**) byKey error:(NSError**) error;
+ (NSSet*) definitionsWithPropertyListData:(NSData*) data definitionsByKey:(NSDictionary**) byKey error:(NSError**) error;

+ (BOOL) writeDefinitions:(NSSet*) definitions toFileAtURL:(NSURL*) url error:(NSError**) error;
+ (NSData*) propertyListDataWithDefinitions:(NSSet*) definitions error:(NSError**) error;

@end
