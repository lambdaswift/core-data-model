import Foundation
import CoreData
import CoreDataModel

// Create the model using the new result builder syntax
let model = CoreDataModel {
    Entity("Todo") {
        Attribute.string("title", isOptional: false)
        Attribute.string("notes", isOptional: true)
        Attribute.boolean("isCompleted", isOptional: false, defaultValue: false)
        Attribute.date("createdAt", isOptional: false, defaultValue: Date())
        Attribute.uuid("id", isOptional: false, defaultValue: UUID())
    }
}

// Create the persistent store coordinator
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model.createModel())

// Create the managed object context
let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
context.persistentStoreCoordinator = coordinator

// Create an in-memory store
try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

// Create a new todo
let todo = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: context) as! NSManagedObject
todo.setValue("Buy groceries", forKey: "title")
todo.setValue("Don't forget milk", forKey: "notes")
todo.setValue(false, forKey: "isCompleted")
todo.setValue(Date(), forKey: "createdAt")
todo.setValue(UUID(), forKey: "id")

// Save the context
try! context.save()

// Fetch all todos
let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Todo", in: context)!
let todos = try! context.fetch(fetchRequest)

// Print the todos
for todo in todos {
    print("Title: \(todo.value(forKey: "title") ?? "")")
    print("Notes: \(todo.value(forKey: "notes") ?? "")")
    print("Completed: \(todo.value(forKey: "isCompleted") ?? false)")
    print("Created: \(todo.value(forKey: "createdAt") ?? Date())")
    print("ID: \(todo.value(forKey: "id") ?? UUID())")
    print("---")
} 