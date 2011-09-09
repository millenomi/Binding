//
//  ILObservingTableSection.h
//  Binding
//
//  Created by ∞ on 09/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
#import "ILTableDataSource.h"

@interface ILObservingTableSection : NSObject <ILTableSection>

- initWithCellCreationBlock:(UITableViewCell*(^)(id object, UITableView* tv)) block;

- (void) setObservedKeyPath:(NSString*) kp ofSourceObject:(id) object;
- (void) endObservingSourceObject;

@property(copy, nonatomic) NSString* indexTitle;
@property(copy, nonatomic) NSString* headerTitle, * footerTitle;

@end

#endif
