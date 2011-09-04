//
//  ILBindingOptions.h
//  Binding
//
//  Created by ∞ on 04/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kILBindingConcurrencyAllowedThread,
} ILBindingConcurrencyModel;

@interface ILBindingOptions : NSObject <NSCopying, NSMutableCopying>

+ optionsWithDefaultValues;
- (id)init;

@property(nonatomic) ILBindingConcurrencyModel concurrencyModel;
@property(nonatomic, retain) NSThread* allowedThread;

@end
