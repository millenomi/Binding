//
//  ILBindingsTestViewController.m
//  ColorPicker
//
//  Created by ∞ on 05/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ILBindingsTestViewController.h"

#import "ILBinding.h"
#import "ILObservingTableSection.h"

@interface ILBindingsTestViewController () <UITableViewDelegate>
@property(retain, nonatomic) ILTableDataSource* dataSource;
@property(retain, nonatomic) ILObservingTableSection* favoritesSection;
@end

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
@synthesize favoritesTableView;
@synthesize colorDisplayView;
@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;

@synthesize dataSource, favoriteColors, favoritesSection;

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    if (!favoriteColors)
        favoriteColors = [NSMutableArray new];
    
    // Load the bindings from the file so the picker works.
    bindings = [[ILBindingsSet bindingsSetNamed:@"ILBindingsTestViewController" owner:self] retain];
    
    // Set up the table view.
    self.favoritesSection = [[[ILObservingTableSection alloc] initWithCellCreationBlock:^UITableViewCell*(id color, UITableView* tv) {
        
        static NSString* const kILBindingsTestFavoriteColorCell = @"kILBindingsTestFavoriteColorCell";
        UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:kILBindingsTestFavoriteColorCell];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kILBindingsTestFavoriteColorCell] autorelease];
        }
        
        cell.textLabel.text = @"A favorite color";
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(29, 29), YES, [UIScreen mainScreen].scale);

        [(UIColor*)color set];
        UIRectFill(CGRectMake(0, 0, 29, 29));
        
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return cell;
        
    }] autorelease];
    [self.favoritesSection setObservedKeyPath:@"favoriteColors" ofSourceObject:self];
    
    self.dataSource = [[[ILTableDataSource alloc] initWithTableView:self.favoritesTableView] autorelease];
    [self.dataSource.sections addObject:self.favoritesSection];
    
    self.favoritesTableView.delegate = self;
    self.favoritesTableView.dataSource = self.dataSource;
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Unbind" style:UIBarButtonItemStyleBordered target:self action:@selector(testByUnbinding)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFavorite)] autorelease];
}

- (void)viewDidUnload {
    [bindings unbind];
    [bindings release]; bindings = nil;
    
    [self.favoritesSection endObservingSourceObject];
    self.favoritesSection = nil;
    
    self.dataSource = nil;
    
    self.favoritesTableView.dataSource = nil;
    self.favoritesTableView.delegate = nil;
    
    [self setRedSlider:nil];
    [self setGreenSlider:nil];
    [self setBlueSlider:nil];
    [self setColorDisplayView:nil];
    [self setFavoritesTableView:nil];
    [super viewDidUnload];
}

- (void) testByUnbinding;
{
    [bindings unbind];
    [bindings release]; bindings = nil;
    
    [self.favoritesSection endObservingSourceObject];
    self.favoritesSection = nil;
}

// --------------------

- (void) addFavorite;
{
    UIColor* color = self.selectedColor;
    [[self mutableArrayValueForKey:@"favoriteColors"] addObject:color];
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UIColor* color = [self.favoriteColors objectAtIndex:indexPath.row];
    self.selectedColor = color;
    
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

// --------------------

@synthesize red, green, blue;

- (UIColor *)selectedColor;
{
    return [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:1.0];
}

- (void)setSelectedColor:(UIColor *)selectedColor;
{
    if (selectedColor) {
        CGFloat r, g, b;
        if ([selectedColor getRed:&r green:&g blue:&b alpha:NULL]) {
            self.red = r;
            self.green = g;
            self.blue = b;
        }
    }
}

+ (NSSet *)keyPathsForValuesAffectingSelectedColor;
{
    return [NSSet setWithObjects:@"red", @"green", @"blue", nil];
}

- (void)dealloc {
    [bindings unbind];
    [bindings release];

    favoritesTableView.delegate = nil;
    favoritesTableView.dataSource = nil;

    [favoritesSection endObservingSourceObject];
    [favoritesSection release];
    
    [dataSource release];
    
    [favoriteColors release];
    
    [redSlider release];
    [greenSlider release];
    [blueSlider release];
    [colorDisplayView release];
    
    [favoritesTableView release];
    [super dealloc];
}

@end
