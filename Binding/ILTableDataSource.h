//
//  ILTableDataSource.h
//  Binding
//
//  Created by ∞ on 09/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
@protocol ILTableSectionDelegate;


@interface ILTableDataSource : NSObject <UITableViewDataSource>

- (id) initWithTableView:(UITableView*) tv;
@property(readonly, nonatomic) UITableView* tableView;

@property(readonly, nonatomic) NSMutableArray* sections;
- (void) setSectionsArray:(NSArray *)sections;

@property(nonatomic) UITableViewRowAnimation reloadAnimation, insertAnimation, deleteAnimation;

@end

// -----------------------------------------


// -----------------------------------------
@protocol ILTableSection <NSObject>

@property(assign, nonatomic) id <ILTableSectionDelegate> delegate;


- (NSInteger) countOfRows;
- (UITableViewCell*) cellForRowAtIndex:(NSInteger) index ofTableView:(UITableView*) tableView;

@optional

- (NSString*) indexTitle;
- (NSString*) headerTitle;
- (NSString*) footerTitle;

- (BOOL) canEditRowAtIndex:(NSInteger) index;
- (BOOL) canMoveRowAtIndex:(NSInteger) index;

@end
// -----------------------------------------

// -----------------------------------------
@protocol ILTableSectionDelegate <NSObject>

- (void) section:(id <ILTableSection>) section didAddRowsAtIndexes:(NSIndexSet*) indexes;
- (void) section:(id <ILTableSection>) section didRemoveRowsAtIndexes:(NSIndexSet*) indexes;
- (void) section:(id <ILTableSection>) section didChangeRowsAtIndexes:(NSIndexSet*) indexes;

- (void) sectionDidChangeAllRows:(id <ILTableSection>) section;

@end
// -----------------------------------------

#endif
