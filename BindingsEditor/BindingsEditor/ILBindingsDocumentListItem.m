//
//  ILBindingDocumentListItem.m
//  BindingsEditor
//
//  Created by ∞ on 07/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingsDocumentListItem.h"
#import "ILBindingsDocument.h"

#define ILKey(x) @#x

@implementation ILBindingsDocumentListItem {
    BOOL lastSetValueWasCustom;
}

- (id) init;
{
    return [self initWithNibName:@"ILBindingsDocumentListItem" bundle:nil];
}

+ (NSSet *)keyPathsForValuesAffectingBindingDefinition;
{
    return [NSSet setWithObject:ILKey(representedObject)];
}

- (ILMutableBindingDefinition *)bindingDefinition;
{
    return (ILMutableBindingDefinition*) self.representedObject;
}

#pragma mark - Value transformer description popup

+ (NSSet *)keyPathsForValuesAffectingValueTransformerDescription;
{
    return [NSSet setWithObject:@"representedObject.valueTransformerName"];
}

- (ILBindingsDocumentValueTransformerDescription) valueTransformerDescription;
{
    NSString* name = self.bindingDefinition.valueTransformerName;
    
    if (!name || [name isEqualToString:@""]) {
        if (lastSetValueWasCustom)
            return kILBindingsDocumentValueTransformerCustom;
        else
            return kILBindingsDocumentValueTransformerNone;
    }
    
    if ([name isEqualToString:NSNegateBooleanTransformerName])
        return kILBindingsDocumentValueTransformerNegateBoolean;
    else if ([name isEqualToString:NSIsNilTransformerName])
        return kILBindingsDocumentValueTransformerIsNil;
    else if ([name isEqualToString:NSIsNotNilTransformerName])
        return kILBindingsDocumentValueTransformerIsNotNil;
    else if ([name isEqualToString:NSKeyedUnarchiveFromDataTransformerName])
        return kILBindingsDocumentValueTransformerKeyedArchive;
    else
        return kILBindingsDocumentValueTransformerCustom;
}

- (void)setValueTransformerDescription:(ILBindingsDocumentValueTransformerDescription) vtd;
{
    ILMutableBindingDefinition* def = self.bindingDefinition;
    
    lastSetValueWasCustom = (vtd == kILBindingsDocumentValueTransformerCustom);
    
/*
 kILBindingsDocumentValueTransformerNone = 1,
 kILBindingsDocumentValueTransformerNegateBoolean,
 kILBindingsDocumentValueTransformerIsNil,
 kILBindingsDocumentValueTransformerIsNotNil,
 kILBindingsDocumentValueTransformerKeyedArchive,
 kILBindingsDocumentValueTransformerCustom,
*/
    
    switch (vtd) {
        case kILBindingsDocumentValueTransformerNone:
        case kILBindingsDocumentValueTransformerCustom:
            def.valueTransformerName = @"";
            break;
            
        case kILBindingsDocumentValueTransformerNegateBoolean:
            def.valueTransformerName = NSNegateBooleanTransformerName;
            break;
            
        case kILBindingsDocumentValueTransformerIsNil:
            def.valueTransformerName = NSIsNilTransformerName;
            break;
            
        case kILBindingsDocumentValueTransformerIsNotNil:
            def.valueTransformerName = NSIsNotNilTransformerName;
            break;
        
        case kILBindingsDocumentValueTransformerKeyedArchive:
            def.valueTransformerName = NSKeyedUnarchiveFromDataTransformerName;
            break;
            
        default:
            break;
    }
}

- (BOOL) hasNoValueTransformerName;
{
    return self.valueTransformerDescription == kILBindingsDocumentValueTransformerNone;
}

#pragma mark - Deletion

- (IBAction)delete:(id)sender;
{
    ILBindingsDocumentList* list = (ILBindingsDocumentList*) self.collectionView;
    
    [list.document removeBinding:self.representedObject];
}

@end
