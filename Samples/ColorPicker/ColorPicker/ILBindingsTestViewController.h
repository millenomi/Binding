//
//  ILBindingsTestViewController.h
//  ColorPicker
//
//  Created by ∞ on 05/09/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
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
@property(readonly, nonatomic) UIColor* selectedColor;

@property(nonatomic) CGFloat red, green, blue;

@end
