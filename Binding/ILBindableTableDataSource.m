//
//  ILBoundTableDataSource.m
//  Binding
//
//  Created by ∞ on 07/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindableTableDataSource.h"
#import "ILBinding.h"

@interface ILBindableTableDataSource ()

@property(retain, nonatomic) UITableView* tableView;

@property(copy, nonatomic) UITableViewCell*(^cellCreationBlock)(id object);

@end

@implementation ILBindableTableDataSource {
    NSMutableArray* mutableContents;
}

@synthesize tableView, cellCreationBlock;
@synthesize reloadAnimation, insertAnimation, deleteAnimation;

- (id) initForTableView:(UITableView*) tv cellCreationBlock:(UITableViewCell*(^)(id object)) block;
{
    self = [super init];
    if (self) {
        self.reloadAnimation = UITableViewRowAnimationFade;
        self.insertAnimation = UITableViewRowAnimationTop;
        self.deleteAnimation = UITableViewRowAnimationRight;
        
        mutableContents = [NSMutableArray new];
        
        self.tableView = tv;
        tv.dataSource = self;
        
        self.cellCreationBlock = block;
    }
    
    return self;
}

- (void)dealloc;
{
    if (self.tableView.dataSource == self)
        self.tableView.dataSource = nil;
    
    self.cellCreationBlock = nil;
    
    [mutableContents release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return mutableContents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id object = [mutableContents objectAtIndex:indexPath.row];
    return cellCreationBlock(object);
}

- (NSArray *)contents;
{
    return mutableContents;
}

- (void)setContents:(NSArray *)contents;
{
    [mutableContents setArray:contents];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:self.reloadAnimation];
}

- (void)insertObject:(id)object inContentsAtIndex:(NSUInteger)index;
{
    [mutableContents insertObject:object atIndex:index];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:self.insertAnimation];
}

- (void)removeObjectFromContentsAtIndex:(NSUInteger)index;
{
    [mutableContents removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:self.insertAnimation];
}

@end
