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
    if (![color getRed:&red green:&green blue:&blue alpha:NULL])
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
    
    if (!bindings)
        bindings = [NSMutableSet new];
    
    [bindings addObject:
     
     [ILBinding bindingWithKeyPath:@"red"
                    ofSourceObject:self
                    boundToKeyPath:@"value"
                 ofTargetUIControl:self.redSlider
                           options:[ILBindingOptions optionsWithDefaultValues]]
     
     ];
    
    [bindings addObject:
     
     [ILBinding bindingWithKeyPath:@"green"
                    ofSourceObject:self
                    boundToKeyPath:@"value"
                 ofTargetUIControl:self.greenSlider
                           options:[ILBindingOptions optionsWithDefaultValues]]
     
     ];
    
    [bindings addObject:
     
     [ILBinding bindingWithKeyPath:@"blue"
                    ofSourceObject:self
                    boundToKeyPath:@"value"
                 ofTargetUIControl:self.blueSlider
                           options:[ILBindingOptions optionsWithDefaultValues]]
     
     ];
    
    
    [bindings addObject:
     
     [ILBinding bindingWithKeyPath:@"selectedColor"
                    ofSourceObject:self
                    boundToKeyPath:@"backgroundColor"
                 ofTargetObject:self.colorDisplayView
                           options:[ILBindingOptions optionsWithDefaultValues]]
     
     ];
    
    
    ILBindingOptions* opts = [ILBindingOptions optionsWithDefaultValues];
    opts.valueTransformer = [[ILBindingsTestBrightnessStringTransformer new] autorelease];
    
    [bindings addObject:
     
     [[ILBinding bindingWithKeyPath:@"selectedColor"
                    ofSourceObject:self
                    boundToKeyPath:@"title"
                    ofTargetObject:self
                           options:opts] setLogging]
     ];
    
}

- (void)viewDidUnload {
    [bindings makeObjectsPerformSelector:@selector(unbind)];
    [bindings removeAllObjects];
    
    [self setRedSlider:nil];
    [self setGreenSlider:nil];
    [self setBlueSlider:nil];
    [self setColorDisplayView:nil];
    [super viewDidUnload];
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
    [bindings makeObjectsPerformSelector:@selector(unbind)];
    [bindings release];
    
    [redSlider release];
    [greenSlider release];
    [blueSlider release];
    [colorDisplayView release];
    
    [super dealloc];
}

@end
