import SwiftUI
import CoreData
import CoreDataModel

@main
struct TodoApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        let model = CoreDataModel {
            Entity("Todo", managedObjectClass: Todo.self) {
                Attribute.string("title", isOptional: false)
                Attribute.boolean("isCompleted", isOptional: false, defaultValue: false)
                Attribute.date("createdAt", isOptional: false, defaultValue: Date())
            }
        }
        
        container = NSPersistentContainer(name: "TodoModel", managedObjectModel: model.createModel())
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.createdAt, ascending: false)],
        animation: .default)
    private var todos: FetchedResults<Todo>
    @State private var newTodoTitle = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        TextField("New Todo", text: $newTodoTitle)
                        Button(action: addTodo) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTodoTitle.isEmpty)
                    }
                }
                
                Section {
                    ForEach(todos) { todo in
                        HStack {
                            Button(action: { toggleTodo(todo) }) {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .green : .gray)
                            }
                            Text(todo.title ?? "")
                                .strikethrough(todo.isCompleted)
                        }
                    }
                    .onDelete(perform: deleteTodos)
                }
            }
            .navigationTitle("Todos")
        }
    }
    
    private func addTodo() {
        withAnimation {
            let newTodo = Todo(context: viewContext)
            newTodo.title = newTodoTitle
            newTodo.isCompleted = false
            newTodo.createdAt = Date()
            newTodoTitle = ""
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving todo: \(error)")
            }
        }
    }
    
    private func toggleTodo(_ todo: Todo) {
        withAnimation {
            todo.isCompleted.toggle()
            try? viewContext.save()
        }
    }
    
    private func deleteTodos(offsets: IndexSet) {
        withAnimation {
            offsets.map { todos[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

// MARK: - Todo Entity
@objc(Todo)
public class Todo: NSManagedObject {
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?
}

extension Todo: Identifiable {}
