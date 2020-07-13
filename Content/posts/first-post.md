---
date: 2020-07-05 15:24
description: A quick look at how passing functions to property wrappers can unlock a bit of reusability.
tags: Swift language features, @propertyWrapper
---
# Reusable property wrappers

## What are property wrappers?

Property wrappers is a feature that was added to Swift 5.1, which lets us decorate properties of different types with @-preceded keywords. Well-known examples are SwiftUI's `@ObservableObject`, `@State` and `@Binding`, just to name a few. We can easily define our own property wrappers, which let's us perform custom logic whenever they're get or set.
 
 The example below creates a property wrapper called `@Lowercased`. The `wrappedValue` property is required, and it's type - `String` in this case - determines which type can be decorated with the property wrapper.

```
@propertyWrapper
struct Lowercased {
    var wrappedValue: String {
        didSet { 
            wrappedValue = wrappedValue.lowercased()
        }
    }
    
    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.lowercased()
    }
}
```

 We could then use this property wrapper as follows.

```
struct User {
    @Lowercased var firstName: String
    @Lowercased var familyName: String
}

let user = User(firstName: "Joe", familyName: "South")
print("Howdy, \(user.firstName) \(user.familyName)!")
//Howdy, joe south!
```

## Pass me that function, please! 

Although `@Lowercased` is a toy example, property wrappers can be very useful. Creating new ones isn't that much of a hassle, but if you're planning on using them heavily there are some things we can do to reduce the amount of boilerplate.
 
 
 
We could create a generic struct that takes the value we're wrapping together with a function that transforms it.

```
@propertyWrapper
struct Transformed<T> {
    private let transform: (T) -> T
    var wrappedValue: T {
        didSet { wrappedValue = transform(wrappedValue) }
    }
    
    init(wrappedValue: T, transform: @escaping (T) -> T) {
        self.transform = transform
        self.wrappedValue = transform(wrappedValue)
    }
}
```

We've now made it easy to define our wrapping logic on the fly.

```
struct User {
    @Transformed var firstName: String
    @Transformed var familyName: String
}

let user = User(
    firstName: Transformed(wrappedValue: "Joe") { $0.uppercased() }, 
    familyName: Transformed(wrappedValue: "South") { $0.lowercased() }
)
```
Rather than passing inline closures, we could easily wrap reusable functionality in an extension...

```
extension Transformed where T == String {
    static func uppercased(_ s: T) -> Transformed<T> {
        Transformed(wrappedValue: s, transform: { $0.uppercased() })
    }
    
    static func lowercased(_ s: T) -> Transformed<T> {
        Transformed(wrappedValue: s, transform: { $0.lowercased() })
    }
}
```

...which makes for a tidier call site.

```
let user = User(
    firstName: .uppercased("Joe"), 
    familyName: .lowercased("South")
)
```

## Wrapper composition 

There might be case when we'd like to add several property wrappers to a property, which is something the Swift compiler doesn't allow. For example, this won't compile

```
//⛔️ Multiple property wrappers are not supported
struct Dog {
    @Capitalized @Prefixed var name: String
}
```

To support chaining transformations, we could modify the `Transformed` struct to hold an array of functions which will be applied to the wrappedValue sequentially each time it's set.

```
@propertyWrapper
struct Transformed<T> {
    private let transforms: [(T) -> T]
    var wrappedValue: T {
        didSet {
            for f in transforms {
                wrappedValue = f(wrappedValue)
            }
        }
    }
    
    init(wrappedValue: T, _ transforms: ((T) -> T)...) {
        self.transforms = transforms
        self.wrappedValue = wrappedValue
        for f in transforms {
            self.wrappedValue = f(self.wrappedValue)
        }
    }
}
```

Now let's try it out!

```
import Foundation

struct Dog {
    @Transformed var name: String
    @Transformed var age: Int
}

var doggie = Dog(
    name: Transformed(
        wrappedValue: "Fido", 
        { $0.capitalized }, 
        { "\($0) the 🐶" }
    ),
    age: Transformed(
        wrappedValue: 2,
        { $0 * 7 }
    )
)

print(doggie.age)

doggie.name = "rolv"
doggie.age = 3

print("Our doggie has a new name, \(doggie.name), and is now \(doggie.age) dog years old")
```

Just as we did earlier, we can course still extend the `Transformed` type with composed functions we would like to be reusable.


