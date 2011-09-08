//
//  ILBindingsDocument.h
//  BindingsEditor
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ILBindingDefinition.h"

@class ILBindingsDocumentList;

@interface ILBindingsDocument : NSDocument

- (IBAction)addBinding:(id) sender;
- (void) removeBinding:(ILMutableBindingDefinition*) binding;

@property (retain) IBOutlet ILBindingsDocumentList *list;

@end


@interface ILBindingsDocumentList : NSCollectionView
@property(assign, nonatomic) IBOutlet ILBindingsDocument* document;
@end

