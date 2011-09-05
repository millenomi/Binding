//
//  ILBinding.h
//  Binding
//
//  Created by ∞ on 03/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ILBindingOptions.h"

@interface ILBinding : NSObject

- initWithKeyPath:(NSString*) key ofSourceObject:(id) object boundToKeyPath:(NSString*) otherKey ofTargetObject:(id) otherObject options:(ILBindingOptions*) options;
- (void) unbind;

@end


#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

@interface ILBinding (ILUIControlBindingAdditions)

- (id)initWithKeyPath:(NSString *)key ofSourceObject:(id)object boundToKeyPath:(NSString *)otherKey ofTargetUIControl:(UIControl*)otherObject options:(ILBindingOptions *)options;

@end

#endif
