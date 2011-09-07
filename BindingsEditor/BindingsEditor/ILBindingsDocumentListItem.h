//
//  ILBindingDocumentListItem.h
//  BindingsEditor
//
//  Created by ∞ on 07/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ILBindingDefinition.h"

@interface ILBindingsDocumentListItem : NSCollectionViewItem

@property(readonly, nonatomic) ILMutableBindingDefinition* bindingDefinition;

@end
