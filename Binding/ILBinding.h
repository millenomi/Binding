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

- initWithKey:(NSString*) key ofObject:(id) object boundToKey:(NSString*) otherKey ofObject:(id) otherObject options:(ILBindingOptions*) options;
- (void) unbind;

@end
