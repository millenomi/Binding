//
//  ILBindingsDocument.m
//  BindingsEditor
//
//  Created by ∞ on 06/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingsDocument.h"

#import "ILBindingDefinition.h"
#import "ILBindingDefinition+ILBindingsLoadingMany.h"

#import "ILBindingsDocumentListItem.h"

@implementation ILBindingsDocumentList

- (void)awakeFromNib;
{
    self.maxItemSize = NSMakeSize(self.frame.size.width, 263);
    self.minItemSize = self.maxItemSize;
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object;
{
    ILBindingsDocumentListItem* item = [ILBindingsDocumentListItem new];
    item.representedObject = object;
    
    return item;
}

@end


@interface ILBindingsDocument ()
@property(retain, nonatomic) NSMutableArray* definitions;
@property(copy, nonatomic) NSIndexSet* selectedIndexes;
@end

@implementation ILBindingsDocument

@synthesize definitions, selectedIndexes;

- (id)init
{
    self = [super init];
    if (self) {
        self.definitions = [NSMutableArray array];
        
        [self addBinding:self];
        [self addBinding:self];
    }
    return self;
}

- (void)dealloc {
    [definitions release];
    [selectedIndexes release];
    [super dealloc];
}

- (NSString *)windowNibName
{
    return @"ILBindingsDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [ILBindingDefinition propertyListDataWithDefinitions:[NSSet setWithArray:self.definitions] error:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSSet* defs = [ILBindingDefinition definitionsWithPropertyListData:data definitionsByKey:NULL error:outError];
    
    if (defs)
        self.definitions = [[[defs allObjects] mutableCopy] autorelease];
    
    return defs != nil;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (IBAction)addBinding:(id)sender;
{
    ILMutableBindingDefinition* definition = [[ILMutableBindingDefinition new] autorelease];
    
    [[self mutableArrayValueForKey:@"definitions"] addObject:definition];
    self.selectedIndexes = [NSIndexSet indexSetWithIndex:self.definitions.count - 1];
}

@end
