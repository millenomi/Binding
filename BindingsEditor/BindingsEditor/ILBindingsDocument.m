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

@synthesize document;

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


@interface ILBindingsDocument () <NSWindowDelegate>
@property(retain, nonatomic) NSMutableArray* definitions;
@property(copy, nonatomic) NSIndexSet* selectedIndexes;
@end

@implementation ILBindingsDocument
@synthesize list;

@synthesize definitions, selectedIndexes;

- (id)init
{
    self = [super init];
    if (self) {
        self.definitions = [NSMutableArray array];
        [self addBinding:self];
    }
    return self;
}

- (void)dealloc {
    self.list.document = nil;

    for (NSWindowController* ctl in self.windowControllers) {
        if ([ctl isWindowLoaded] && ctl.window.delegate == self)
            ctl.window.delegate = nil;
    }
    
    [list release];
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
    
    aController.window.delegate = self;
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize;
{
    return NSMakeSize(sender.frame.size.width, frameSize.height);
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [ILBindingDefinition propertyListDataWithDefinitions:[NSSet setWithArray:self.definitions] error:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSArray* defs = [ILBindingDefinition definitionsWithPropertyListData:data options:kILBindingLoadingAllowIncompleteOrDuplicateDefinitions definitionsByKey:NULL error:outError];
    
    if (defs) {
        NSMutableArray* mutableCopies = [NSMutableArray arrayWithCapacity:defs.count];
        
        for (ILBindingDefinition* def in defs)
            [mutableCopies addObject:[[def mutableCopy] autorelease]];
        
        self.definitions = mutableCopies;
    }
    
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

- (void) removeBinding:(ILMutableBindingDefinition*) binding;
{
    [[self mutableArrayValueForKey:@"definitions"] removeObject:binding];
}

#pragma mark - Undo support

- (void)insertObject:(ILMutableBindingDefinition *)definition inDefinitionsAtIndex:(NSUInteger)index;
{
    for (NSString* key in [ILMutableBindingDefinition allObservableKeys])
        [definition addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld context:NULL];
    
    [definitions insertObject:definition atIndex:index];
}

- (void)removeObjectFromDefinitionsAtIndex:(NSUInteger)index;
{
    ILMutableBindingDefinition* definition = [definitions objectAtIndex:index];
    
    for (NSString* key in [ILMutableBindingDefinition allObservableKeys])
        [definition removeObserver:self forKeyPath:key];
    
    [definitions removeObjectAtIndex:index];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    NSAssert([[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue] == NSKeyValueChangeSetting, @"Only set operations are assumed to occur on ILMutableBindingDefinition keys");
    [[self.undoManager prepareWithInvocationTarget:object] setValue:[change objectForKey:NSKeyValueChangeOldKey] forKeyPath:keyPath];
}

@end
