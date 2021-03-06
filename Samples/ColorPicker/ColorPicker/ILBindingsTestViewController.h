//
//  ILBindingsTestViewController.h
//  ColorPicker
//
//  Created by ∞ on 05/09/11.
//  Copyright (c) 2011 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILBindingsSet.h"

@interface ILBindingsTestViewController : UIViewController {
    ILBindingsSet* bindings;
}

@property (retain, nonatomic) IBOutlet UIView *colorDisplayView;

@property (retain, nonatomic) IBOutlet UISlider *redSlider;
@property (retain, nonatomic) IBOutlet UISlider *greenSlider;
@property (retain, nonatomic) IBOutlet UISlider *blueSlider;

// Model
@property(copy, nonatomic) UIColor* selectedColor;
@property(nonatomic) CGFloat red, green, blue;

@property(retain, nonatomic) NSMutableArray* favoriteColors;

// Favorites
@property (retain, nonatomic) IBOutlet UITableView *favoritesTableView;

@end
