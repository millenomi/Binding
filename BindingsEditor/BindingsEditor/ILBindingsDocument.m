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

@interface ILBindingsDocument ()
@property(retain, nonatomic) NSMutableArray* definitions;
@end

@implementation ILBindingsDocument

@synthesize definitions;

- (id)init
{
    self = [super init];
    if (self) {
        self.definitions = [NSMutableArray array];
    }
    return self;
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

- (IBAction)addBinding:(id)sender {
}
@end
