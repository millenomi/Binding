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
