//
//  ILBindableTableDataSource.h
//  Binding
//
//  Created by ∞ on 07/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
#import "ILBinding.h"

@interface ILBindableTableDataSource : NSObject <UITableViewDataSource>

- (id) initForTableView:(UITableView*) tv cellCreationBlock:(UITableViewCell*(^)(id object)) block;

@property(copy, nonatomic) NSArray* contents;

@property(nonatomic) UITableViewRowAnimation reloadAnimation, insertAnimation, deleteAnimation;

@end

#endif
