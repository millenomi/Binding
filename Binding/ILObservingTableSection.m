//
//  ILObservingTableSection.m
//  Binding
//
//  Created by ∞ on 09/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILObservingTableSection.h"

@interface ILObservingTableSection ()

@property(assign, nonatomic) id object;
@property(copy, nonatomic) NSString* keyPath;

@property(copy, nonatomic) UITableViewCell*(^cellCreationBlock)(id object, UITableView* tv);

@end

@implementation ILObservingTableSection

@synthesize delegate;

@synthesize object, keyPath;
@synthesize cellCreationBlock;

@synthesize indexTitle, headerTitle, footerTitle;

- initWithCellCreationBlock:(UITableViewCell*(^)(id object, UITableView* tv)) block;
{
    self = [super init];
    if (self)
        self.cellCreationBlock = block;
    
    return self;
}

- (void)dealloc;
{
    [self endObservingSourceObject];
    
    [cellCreationBlock release];
    
    [indexTitle release];
    [headerTitle release];
    [footerTitle release];
    
    [super dealloc];
}


- (void)setObservedKeyPath:(NSString *)kp ofSourceObject:(id)o;
{
    [self endObservingSourceObject];
    
    self.object = o;
    self.keyPath = kp;
    
    [o addObserver:self forKeyPath:kp options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)endObservingSourceObject;
{
    [self.object removeObserver:self forKeyPath:self.keyPath];
    
    self.object = nil;
    self.keyPath = nil;
    
    [self.delegate sectionDidChangeAllRows:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (!self.delegate)
        return;
    
    NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    
    switch (kind) {
        case NSKeyValueChangeSetting:
            [self.delegate sectionDidChangeAllRows:self];
            break;
            
        case NSKeyValueChangeReplacement:
            [self.delegate section:self didChangeRowsAtIndexes:[change objectForKey:NSKeyValueChangeIndexesKey]];
            break;
            
        case NSKeyValueChangeInsertion:
            [self.delegate section:self didAddRowsAtIndexes:[change objectForKey:NSKeyValueChangeIndexesKey]];
            break;
            
        case NSKeyValueChangeRemoval:
            [self.delegate section:self didRemoveRowsAtIndexes:[change objectForKey:NSKeyValueChangeIndexesKey]];
            break;            
    }
}

- (NSInteger)countOfRows;
{
    if (!self.object)
        return 0;
    
    return [[self.object valueForKey:self.keyPath] count];
}

- (UITableViewCell *)cellForRowAtIndex:(NSInteger)index ofTableView:(UITableView *)tv;
{
    id value = [[self.object valueForKey:self.keyPath] objectAtIndex:index];
    return (self.cellCreationBlock)(value, tv);
}

@end
