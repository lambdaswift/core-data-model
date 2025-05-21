# CoreDataModel

[![CI](https://github.com/lambdaswift/core-data-model/actions/workflows/ci.yml/badge.svg)](https://github.com/lambdaswift/core-data-model/actions/workflows/ci.yml)
[![Swift](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Swift package that provides a declarative, type-safe way to build Core Data models in code.

## Overview

CoreDataModel makes it easier to define Core Data models using Swift, providing a more intuitive and maintainable way to create your data models compared to the traditional Xcode model editor or programmatic approach.

## Minimal Example

Here's a complete example of a Todo app using CoreDataModel:

```swift
import CoreDataModel
import CoreData

// Define your NSManagedObject subclass
@objc(Todo)
public class Todo: NSManagedObject {
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?
}

extension Todo: Identifiable {}

// Create the Core Data model
let model = CoreDataModel {
    Entity("Todo", managedObjectClass: Todo.self) {
        Attribute.string("title", isOptional: false)
        Attribute.boolean("isCompleted", isOptional: false, defaultValue: false)
        Attribute.date("createdAt", isOptional: false, defaultValue: Date())
    }
}

// Set up the persistent container
let container = NSPersistentContainer(name: "Todo", managedObjectModel: model.createModel())
container.loadPersistentStores { description, error in
    if let error = error {
        fatalError("Failed to load store: \(error)")
    }
}
```

## Example App

The repository includes a complete Todo app example that demonstrates:
- Core Data model definition using CoreDataModel
- SwiftUI integration with `@FetchRequest`
- CRUD operations (Create, Read, Update, Delete)
- Proper Core Data context management
- Persistent storage
- Automatic managed object class configuration

You can find the example in the `Examples/TodoExample` directory.

## Features

- Declarative model definition in code
- Type-safe entity and attribute definitions
- Automatic managed object class configuration
- Automatic relationship management
- Support for all Core Data attribute types
- Migration support

## Installation

Add the package to your Xcode project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/lambdaswift/CoreDataModel.git", from: "0.0.1")
]
```

## Usage

Here's a simple example of how to define a Core Data model using CoreDataModel:

```swift
import CoreDataModel

// Define your NSManagedObject subclasses
@objc(Person)
public class Person: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var age: Int16
    @NSManaged public var birthDate: Date?
    @NSManaged public var addresses: Set<Address>?
    @NSManaged public var department: Department?
}

@objc(Address)
public class Address: NSManagedObject {
    @NSManaged public var street: String?
    @NSManaged public var city: String?
    @NSManaged public var zipCode: String?
    @NSManaged public var person: Person?
}

@objc(Department)
public class Department: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var manager: Person?
    @NSManaged public var employees: Set<Person>?
    @NSManaged public var projects: Set<Project>?
}

// Create the Core Data model
let model = CoreDataModel {
    Entity("Person", managedObjectClass: Person.self) {
        Attribute.string("name")
        Attribute.integer16("age")
        Attribute.date("birthDate")
        Relationship(name: "addresses", destination: "Address", isToMany: true)
        Relationship(name: "department", destination: "Department")
    }
    
    Entity("Address", managedObjectClass: Address.self) {
        Attribute.string("street")
        Attribute.string("city")
        Attribute.string("zipCode")
        Relationship(name: "person", destination: "Person")
    }
    
    Entity("Department", managedObjectClass: Department.self) {
        Attribute.string("name")
        Relationship(name: "manager", destination: "Person")
        Relationship(name: "employees", destination: "Person", isToMany: true)
        Relationship(name: "projects", destination: "Project", isToMany: true, deleteRule: .cascadeDeleteRule)
    }
}

let coreDataModel = model.createModel()
```

### Supported Attribute Types

- .string
- .integer16
- .integer32
- .integer64
- .decimal
- .double
- .float
- .boolean
- .date
- .binary
- .transformable
- .uuid
- .uri
- .objectID

### Relationships

Define relationships using the `Relationship` struct:

```swift
Entity("Department", managedObjectClass: Department.self) {
    Attribute.string("name")
    Relationship(name: "manager", destination: "Person")
    Relationship(name: "employees", destination: "Person", isToMany: true)
    Relationship(name: "projects", destination: "Project", isToMany: true, deleteRule: .cascadeDeleteRule)
}
```

### Delete Rules

CoreDataModel supports all Core Data delete rules:
- `.nullifyDeleteRule` (default)
- `.cascadeDeleteRule`
- `.denyDeleteRule`
- `.noActionDeleteRule`

Example:
```swift
Entity("Employee", managedObjectClass: Employee.self) {
    Attribute.string("name")
    Relationship(name: "department", destination: "Department")
    Relationship(name: "tasks", destination: "Task", isToMany: true, deleteRule: .cascadeDeleteRule)
    Relationship(name: "activeProjects", destination: "Project", isToMany: true, deleteRule: .denyDeleteRule)
}
```

## Benefits

- **Type Safety**: Catch errors at compile time rather than runtime
- **Code Reusability**: Share model definitions across projects
- **Version Control**: Track model changes in source control
- **Maintainability**: Easier to understand and modify models
- **Documentation**: Self-documenting code with clear structure
- **Automatic Configuration**: Managed object classes are automatically configured

## Requirements

- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+ / watchOS 10.0+ / visionOS 1.0+
- Swift 5.10+
- Xcode 15.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 