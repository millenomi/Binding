//
//  ILBindingsTestViewController.m
//  ColorPicker
//
//  Created by ∞ on 05/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingsTestViewController.h"

#import "ILBinding.h"

@interface ILBindingsTestBrightnessStringTransformer : NSValueTransformer
@end

@implementation ILBindingsTestBrightnessStringTransformer

+ (Class)transformedValueClass;
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation;
{
    return NO;
}

- (id)transformedValue:(id)value;
{
    if (!value)
        return nil;

    UIColor* color = value;
    CGFloat red, green, blue;
    
    // <#TODO#> Report bug: iOS 5 headers don't mark this method with *_AVAILABLE(*, 5_0).
    if (![color respondsToSelector:@selector(getRed:green:blue:alpha:)] || ![color getRed:&red green:&green blue:&blue alpha:NULL])
        return @"Unknown";
    
    CGFloat average = (red + green + blue) / 3.0;
    if (average < 0.1)
        return @"Black";
    else if (average >= 0.1 && average < 0.5)
        return @"Dark";
    else if (average >= 0.5 && average < 0.9)
        return @"Bright";
    else
        return @"White";
}

@end

@implementation ILBindingsTestViewController
@synthesize colorDisplayView;
@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    bindings = [[ILBindingsSet bindingsSetNamed:@"ILBindingsTestViewController" owner:self] retain];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Unbind" style:UIBarButtonItemStyleBordered target:self action:@selector(testByUnbinding)] autorelease];
}

- (void)viewDidUnload {
    [bindings unbind];
    [bindings release]; bindings = nil;
    
    [self setRedSlider:nil];
    [self setGreenSlider:nil];
    [self setBlueSlider:nil];
    [self setColorDisplayView:nil];
    [super viewDidUnload];
}

- (void) testByUnbinding;
{
    [bindings unbind];
    [bindings release]; bindings = nil;
}

// --------------------

@synthesize red, green, blue;

- (UIColor *)selectedColor;
{
    return [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:1.0];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedColor;
{
    return [NSSet setWithObjects:@"red", @"green", @"blue", nil];
}

- (void)dealloc {
    [bindings unbind];
    [bindings release];
    
    [redSlider release];
    [greenSlider release];
    [blueSlider release];
    [colorDisplayView release];
    
    [super dealloc];
}

@end
