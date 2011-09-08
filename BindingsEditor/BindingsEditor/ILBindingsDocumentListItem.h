//
//  ILBindingDocumentListItem.h
//  BindingsEditor
//
//  Created by ∞ on 07/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ILBindingDefinition.h"

typedef enum {
    kILBindingsDocumentValueTransformerNone = 1,
    kILBindingsDocumentValueTransformerNegateBoolean,
    kILBindingsDocumentValueTransformerIsNil,
    kILBindingsDocumentValueTransformerIsNotNil,
    kILBindingsDocumentValueTransformerKeyedArchive,
    kILBindingsDocumentValueTransformerCustom,
} ILBindingsDocumentValueTransformerDescription;

@interface ILBindingsDocumentListItem : NSCollectionViewItem

@property(readonly, nonatomic) ILMutableBindingDefinition* bindingDefinition;

@property(nonatomic) ILBindingsDocumentValueTransformerDescription valueTransformerDescription;

- (IBAction)delete:(id)sender;

@property(readonly, nonatomic, getter = isInViewingMode) BOOL inViewingMode;

@end
