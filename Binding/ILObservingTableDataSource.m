//
//  ILBoundTableDataSource.m
//  Binding
//
//  Created by ∞ on 07/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILObservingTableDataSource.h"
#import "ILBinding.h"

@interface ILObservingTableDataSource ()

@property(retain, nonatomic) UITableView* tableView;

@property(copy, nonatomic) UITableViewCell*(^cellCreationBlock)(id object);

@property(assign, nonatomic) id observedObject;
@property(copy, nonatomic) NSString* observedKeyPath;

- (NSArray*) indexPathsForIndexes:(NSIndexSet*) indexes inSection:(NSInteger) section;

@end

@implementation ILObservingTableDataSource

@synthesize tableView, cellCreationBlock;
@synthesize reloadAnimation, insertAnimation, deleteAnimation;
@synthesize observedObject, observedKeyPath;

- (id) initForTableView:(UITableView*) tv cellCreationBlock:(UITableViewCell*(^)(id object)) block;
{
    self = [super init];
    if (self) {
        self.reloadAnimation = UITableViewRowAnimationFade;
        self.insertAnimation = UITableViewRowAnimationTop;
        self.deleteAnimation = UITableViewRowAnimationRight;
        
        self.tableView = tv;
        tv.dataSource = self;
        
        self.cellCreationBlock = block;
    }
    
    return self;
}

- (void)dealloc;
{
    [self endObservingSourceObject];
    
    if (self.tableView.dataSource == self)
        self.tableView.dataSource = nil;
    
    self.cellCreationBlock = nil;
    
    [super dealloc];
}

- (void) setObservedKeyPath:(NSString*) kp ofSourceObject:(id) object;
{
    [self endObservingSourceObject];
    
    self.observedObject = object;
    self.observedKeyPath = kp;
    
    [object addObserver:self forKeyPath:self.observedKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:self.reloadAnimation];
}

- (void) endObservingSourceObject;
{
    [self.observedObject removeObserver:self forKeyPath:self.observedKeyPath];
    
    self.observedObject = nil;
    self.observedKeyPath = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (!self.observedObject)
        return 0;
    
    return [self.observedObject mutableArrayValueForKey:self.observedKeyPath].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id object = [[self.observedObject mutableArrayValueForKey:self.observedKeyPath] objectAtIndex:indexPath.row];
    return cellCreationBlock(object);
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    
    switch (kind) {
        case NSKeyValueChangeSetting:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:self.reloadAnimation];
            break;
            
        case NSKeyValueChangeReplacement: {
            NSArray* paths = [self indexPathsForIndexes:[change objectForKey:NSKeyValueChangeIndexesKey] inSection:0];
            
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:self.reloadAnimation];
        }
            break;
            
        case NSKeyValueChangeInsertion: {
            NSArray* paths = [self indexPathsForIndexes:[change objectForKey:NSKeyValueChangeIndexesKey] inSection:0];
            
            [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:self.insertAnimation];
        }
            break;
            
        case NSKeyValueChangeRemoval: {
            NSArray* paths = [self indexPathsForIndexes:[change objectForKey:NSKeyValueChangeIndexesKey] inSection:0];
            
            [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:self.deleteAnimation];
        }
            break;            
    }
}

- (NSArray*) indexPathsForIndexes:(NSIndexSet*) indexes inSection:(NSInteger) section;
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:indexes.count];
    
    NSInteger i = [indexes firstIndex];
    while (i != NSNotFound) {
        [array addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        i = [indexes indexGreaterThanIndex:i];
    }
    
    return array;
}

- (id) objectAtTableViewIndexPath:(NSIndexPath*) path;
{
    return [[self.observedObject mutableArrayValueForKey:self.observedKeyPath] objectAtIndex:path.row];
}

@end
