//
//  BindingTests.m
//  BindingTests
//
//  Created by ∞ on 04/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BindingTests.h"

#import "ILBinding.h"

@interface ILBindingTestObject : NSObject
@property(copy, nonatomic) NSString* someString;
@end

@implementation ILBindingTestObject
@synthesize someString;
@end

@interface BindingTests ()
@property(retain, nonatomic) ILBindingTestObject* a, * b;
@end


@implementation BindingTests

@synthesize a, b;

- (void)setUp
{
    [super setUp];
    
    self.a = [[ILBindingTestObject new] autorelease];
    self.b = [[ILBindingTestObject new] autorelease];
}

- (void)tearDown
{
    self.a = nil;
    self.b = nil;
    
    [super tearDown];
}

- (void) testSimpleBinding;
{
    ILBinding* binding = [[[ILBinding alloc] initBindingKey:@"someString" ofObject:self.a toKey:@"someString" ofObject:self.b options:[ILBindingOptions optionsWithDefaultValues]] autorelease];
    
    self.a.someString = @"This is a test";
    STAssertEqualObjects(self.b.someString, self.a.someString, @"The binding changed the string key on setting.");
    
    self.b.someString = @"This is a reciprocal test";
    STAssertEqualObjects(self.b.someString, self.a.someString, @"The binding changed the string key on setting.");
    
    [binding unbind];
    
    self.a.someString = @"This is another test";
    STAssertFalse([self.b.someString isEqual:self.a.someString], @"The binding did not change the string key on setting after unbinding.");
}

@end
