# Bindings for iOS 

On Mac OS X, Cocoa provides developers with the concept of *bindings*: a quick, declarative way for controllers to define the flow of data between objects, mainly useful for synchronizing views with models and vice versa. The use of bindings can reduce or eliminate the amount of boilerplate code you'd otherwise need to write to keep things in sync.

This library contains a reimplementation of that mechanism that works on iOS. It also tweaks the mechanism a little so that UIKit controls can more easily participate in bindings, by automatically handling `UIControlEventValueChanged` messages.

For an example of use, see the `Samples/ColorPicker` project in this repository.

## Usage

To set up your project to use this library, add its corresponding source files to your project, or compile it to a `.a` static library file and copy the headers as needed. Make sure you also add the `-ObjC` flag to the `Other Linker Flags` setting of your target.

To bind two key paths together, simply create a `ILBinding` object by specifying what objects to bind. For example:

	self.binding = [ILBinding
					bindingWithKeyPath:@"someKeyPath"
					    ofSourceObject:self.model
					    boundToKeyPath:@"aView.someOtherKeyPath"
					    ofTargetObject:self
					           options:nil];

As you can see, a binding takes a *source* object and binds one of its key paths to the key path of the *target* object. Typically, you will pass a model object as the source and a controller or view object as the target. The default options make distinguishing source and target a bit moot, as they sync every change both ways, but you can pass a `ILBindingOptions` object to the "`options:`…" part of the method to change how the binding behaves, which can make the distinction relevant.

Just like bindings on Mac OS X, neither object is retained. Before either object becomes invalid, you must call the `-unbind` method on this binding to make it stop working, typically in `-dealloc` and/or in `-viewDidLoad` for a `UIViewController`. Bindings are "one-use-only": once created, they only work for the key paths specified at creation time (can't be 'retargeted') and once unbound, they will not perform any further operation (can't be 'reused').

### Bindings Sets

Since you typically work with a *set* of bindings, rather than just one, it's more convenient to use the included Bindings Editor application to describe which bindings you will need, put that definition file into a project, then use the `ILBindingsSet` class to create all bindings at once when needed. For example:

	// BindingsFile.ilabs-bindings was created with the editor and included in this app as a resource.
	self.bindingsSet = [ILBindingsSet bindingsSetNamed:@"BindingsFile" owner:self];

You specify which objects are bound in the definition file using key paths that will be evaluated starting from the *owner object* passed above. For example, given `self` the owner object, to bind `self.importancyValue` to the `value` property of `self.slider`, you specify in the bindings file:

* Source object: `self`
* Source bound key path: `importancyValue`
* Target object: `slider`
* Target bound key path: `value`

The object key paths are resolved only once, when you load the bindings set, and are not watched. The bound paths are watched via KVO.

You must unbind all bindings created by the set, just like in the programmatic case above. To do so, you can use the bindings set convenience method `-unbind`, which will perform this operation on all bindings in the set.

Not all options are available to bindings created using the definition file. You can, however, mix and match loading from a file and creating programmatically as you need.

### Working with UIControls

UIKit does not support KVO directly. However, if you specify as your *target* object a `UIControl`, then the binding will observe changes done to it by the user in a supported way (using the 'Value Changed' control event).

`UIControl` support is automatic for bindings sets. If you are programmatically creating bindings, you will need to call the `bindingWithKeyPath:ofSourceObject:boundToKeyPath:ofTargetUIControl:options:` method instead of the usual constructor, which will set up the binding differently for the `UIControl` instance.

Note that `UIControl`s are not supported in any other location (as source objects, or in any location within bound key paths).

### Table utilities

**Documentation forthcoming**

## Design

Similarly to what happens on Mac OS X, bindings are conceptually "leaf" objects that do not retain their referenced object. Unlike Mac OS X, however, a binding isn't just a relationship between objects, but it's reified into an actual (`ILBinding`) object itself, so it can be queried or manipulated later. This is intended to simplify debugging operations involving bindings, one of Mac OS X's greatest weaknesses.

The full Bindings Editor stack is available as part of the library; you can create or manipulate "binding definitions" programmatically, and save, edit and load binding definition files produced by the Editor at your leisure. See the `ILBindingDefinition` class and its class methods for more.

Although table utilities are not directly related to bindings, they cover an area that bindings traditionally cover on Mac OS X: that of displaying a set of objects to the user. The model is imperfect, but will help many apps that, while KVO compliant, still require a large amount of code to keep visual representations of their collections in sync.

**More documentation forthcoming**

## Examples

## Authors
