# Bindings for iOS 

On Mac OS X, Cocoa provides developers with the concept of *bindings*: a quick, declarative way for controllers to define the flow of data between objects, mainly useful for synchronizing views with models and vice versa. The use of bindings can reduce or eliminate the amount of boilerplate code you'd otherwise need to write to keep things in sync.

This library contains a reimplementation of that mechanism that works on iOS. It also tweaks the mechanism a little so that UIKit controls can more easily participate in bindings, by automatically handling `UIControlEventValueChanged` messages.

For an example of use, see the `Samples/ColorPicker` project in this repository.

**Documentation forthcoming**

## Usage


## Design


## Examples


## Authors
