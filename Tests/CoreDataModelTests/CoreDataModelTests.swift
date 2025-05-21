import XCTest
import CoreData
@testable import CoreDataModel

// Test managed object classes
@objc(TestPerson)
class TestPerson: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var age: Int16
    @NSManaged var address: TestAddress?
}

@objc(TestAddress)
class TestAddress: NSManagedObject {
    @NSManaged var street: String?
    @NSManaged var person: TestPerson?
}

@objc(TestDepartment)
class TestDepartment: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var employees: Set<TestPerson>?
}

@objc(TestEmployee)
class TestEmployee: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var department: TestDepartment?
}

@objc(TestStudent)
class TestStudent: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var courses: Set<TestCourse>?
}

@objc(TestCourse)
class TestCourse: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var students: Set<TestStudent>?
}

@objc(TestEntity)
class TestEntity: NSManagedObject {
    @NSManaged var string: String?
    @NSManaged var integer16: Int16
    @NSManaged var integer32: Int32
    @NSManaged var integer64: Int64
    @NSManaged var decimal: Decimal
    @NSManaged var double: Double
    @NSManaged var float: Float
    @NSManaged var boolean: Bool
    @NSManaged var date: Date?
    @NSManaged var binary: Data?
    @NSManaged var transformable: Data?
    @NSManaged var uuid: UUID?
    @NSManaged var uri: URL?
}

@objc(TestShoppingList)
class TestShoppingList: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var items: Set<TestShoppingListItem>?
}

@objc(TestShoppingListItem)
class TestShoppingListItem: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var shoppingList: TestShoppingList?
}

final class CoreDataModelTests: XCTestCase {
    func testBasicModelCreation() {
        let model = CoreDataModel {
            Entity("Person", managedObjectClass: TestPerson.self) {
                Attribute.string("name")
                Attribute.integer16("age")
            }
        }
        
        let coreDataModel = model.createModel()
        XCTAssertEqual(coreDataModel.entities.count, 1)
        
        let personEntity = coreDataModel.entities.first
        XCTAssertEqual(personEntity?.name, "Person")
        XCTAssertEqual(personEntity?.properties.count, 2)
        XCTAssertEqual(personEntity?.managedObjectClassName, NSStringFromClass(TestPerson.self))
    }
    
    func testEntityWithRelationships() {
        let model = CoreDataModel {
            Entity("Person", managedObjectClass: TestPerson.self) {
                Attribute.string("name")
                Relationship(name: "address", destination: "Address")
            }
            
            Entity("Address", managedObjectClass: TestAddress.self) {
                Attribute.string("street")
                Relationship(name: "person", destination: "Person")
            }
        }
        
        let coreDataModel = model.createModel()
        XCTAssertEqual(coreDataModel.entities.count, 2)
        
        let personEntity = coreDataModel.entities.first { $0.name == "Person" }
        let addressEntity = coreDataModel.entities.first { $0.name == "Address" }
        
        XCTAssertNotNil(personEntity)
        XCTAssertNotNil(addressEntity)
        XCTAssertEqual(personEntity?.managedObjectClassName, NSStringFromClass(TestPerson.self))
        XCTAssertEqual(addressEntity?.managedObjectClassName, NSStringFromClass(TestAddress.self))
        
        let personAddressRelationship = personEntity?.relationshipsByName["address"] as? NSRelationshipDescription
        let addressPersonRelationship = addressEntity?.relationshipsByName["person"] as? NSRelationshipDescription
        
        XCTAssertNotNil(personAddressRelationship)
        XCTAssertNotNil(addressPersonRelationship)
        
        XCTAssertEqual(personAddressRelationship?.destinationEntity, addressEntity)
        XCTAssertEqual(addressPersonRelationship?.destinationEntity, personEntity)
    }
    
    func testRelationshipDeleteRules() {
        let model = CoreDataModel {
            Entity("Department", managedObjectClass: TestDepartment.self) {
                Attribute.string("name")
                Relationship(name: "employees", destination: "Employee", isToMany: true, deleteRule: .cascadeDeleteRule)
            }
            
            Entity("Employee", managedObjectClass: TestEmployee.self) {
                Attribute.string("name")
                Relationship(name: "department", destination: "Department")
            }
        }
        
        let coreDataModel = model.createModel()
        let departmentEntity = coreDataModel.entities.first { $0.name == "Department" }
        let employeeEntity = coreDataModel.entities.first { $0.name == "Employee" }
        
        XCTAssertEqual(departmentEntity?.managedObjectClassName, NSStringFromClass(TestDepartment.self))
        XCTAssertEqual(employeeEntity?.managedObjectClassName, NSStringFromClass(TestEmployee.self))
        
        let employeesRelationship = departmentEntity?.relationshipsByName["employees"] as? NSRelationshipDescription
        let departmentRelationship = employeeEntity?.relationshipsByName["department"] as? NSRelationshipDescription
        
        XCTAssertEqual(employeesRelationship?.deleteRule, .cascadeDeleteRule)
        XCTAssertEqual(departmentRelationship?.deleteRule, .nullifyDeleteRule)
    }
    
    func testOptionalAttributes() {
        let model = CoreDataModel {
            Entity("Person", managedObjectClass: TestPerson.self) {
                Attribute.string("name", isOptional: false)
                Attribute.string("nickname", isOptional: true)
            }
        }
        
        let coreDataModel = model.createModel()
        let personEntity = coreDataModel.entities.first
        
        XCTAssertEqual(personEntity?.managedObjectClassName, NSStringFromClass(TestPerson.self))
        
        let nameAttribute = personEntity?.attributesByName["name"] as? NSAttributeDescription
        let nicknameAttribute = personEntity?.attributesByName["nickname"] as? NSAttributeDescription
        
        XCTAssertFalse(nameAttribute?.isOptional ?? true)
        XCTAssertTrue(nicknameAttribute?.isOptional ?? false)
    }
    
    func testManyToManyRelationship() {
        let model = CoreDataModel {
            Entity("Student", managedObjectClass: TestStudent.self) {
                Attribute.string("name")
                Relationship(name: "courses", destination: "Course", isToMany: true)
            }
            
            Entity("Course", managedObjectClass: TestCourse.self) {
                Attribute.string("name")
                Relationship(name: "students", destination: "Student", isToMany: true)
            }
        }
        
        let coreDataModel = model.createModel()
        let studentEntity = coreDataModel.entities.first { $0.name == "Student" }
        let courseEntity = coreDataModel.entities.first { $0.name == "Course" }
        
        XCTAssertEqual(studentEntity?.managedObjectClassName, NSStringFromClass(TestStudent.self))
        XCTAssertEqual(courseEntity?.managedObjectClassName, NSStringFromClass(TestCourse.self))
        
        let coursesRelationship = studentEntity?.relationshipsByName["courses"] as? NSRelationshipDescription
        let studentsRelationship = courseEntity?.relationshipsByName["students"] as? NSRelationshipDescription
        
        XCTAssertEqual(coursesRelationship?.maxCount, 0) // Unlimited
        XCTAssertEqual(studentsRelationship?.maxCount, 0) // Unlimited
    }
    
    func testAllAttributeTypes() {
        let model = CoreDataModel {
            Entity("Test", managedObjectClass: TestEntity.self) {
                Attribute.string("string")
                Attribute.integer16("integer16")
                Attribute.integer32("integer32")
                Attribute.integer64("integer64")
                Attribute.decimal("decimal")
                Attribute.double("double")
                Attribute.float("float")
                Attribute.boolean("boolean")
                Attribute.date("date")
                Attribute.binary("binary")
                Attribute.transformable("transformable", defaultValue: Data())
                Attribute.uuid("uuid")
                Attribute.uri("uri")
            }
        }
        
        let coreDataModel = model.createModel()
        let testEntity = coreDataModel.entities.first
        
        XCTAssertEqual(testEntity?.managedObjectClassName, NSStringFromClass(TestEntity.self))
        XCTAssertEqual(testEntity?.properties.count, 13)
        
        let attributes = testEntity?.attributesByName
        XCTAssertNotNil(attributes?["string"])
        XCTAssertNotNil(attributes?["integer16"])
        XCTAssertNotNil(attributes?["integer32"])
        XCTAssertNotNil(attributes?["integer64"])
        XCTAssertNotNil(attributes?["decimal"])
        XCTAssertNotNil(attributes?["double"])
        XCTAssertNotNil(attributes?["float"])
        XCTAssertNotNil(attributes?["boolean"])
        XCTAssertNotNil(attributes?["date"])
        XCTAssertNotNil(attributes?["binary"])
        XCTAssertNotNil(attributes?["transformable"])
        XCTAssertNotNil(attributes?["uuid"])
        XCTAssertNotNil(attributes?["uri"])
    }
    
    func testManagedObjectClassConfiguration() {
        let model = CoreDataModel {
            Entity("Person", managedObjectClass: TestPerson.self) {
                Attribute.string("name")
            }
        }
        
        let coreDataModel = model.createModel()
        let personEntity = coreDataModel.entities.first
        
        XCTAssertEqual(personEntity?.managedObjectClassName, NSStringFromClass(TestPerson.self))
    }
    
    func testEntityWithoutManagedObjectClass() {
        let model = CoreDataModel {
            Entity("Person") {
                Attribute.string("name")
            }
        }
        
        let coreDataModel = model.createModel()
        let personEntity = coreDataModel.entities.first
        
        XCTAssertEqual(personEntity?.managedObjectClassName, NSStringFromClass(NSManagedObject.self))
    }
    
    func testInverseRelationships() {
        let model = CoreDataModel {
            Entity("ShoppingList", managedObjectClass: TestShoppingList.self) {
                Attribute.string("name")
                Relationship(
                    name: "items",
                    destination: "ShoppingListItem",
                    isToMany: true,
                    inverse: "shoppingList"
                )
            }
            
            Entity("ShoppingListItem", managedObjectClass: TestShoppingListItem.self) {
                Attribute.string("name")
                Relationship(
                    name: "shoppingList",
                    destination: "ShoppingList",
                    inverse: "items"
                )
            }
        }
        
        let coreDataModel = model.createModel()
        let shoppingListEntity = coreDataModel.entities.first { $0.name == "ShoppingList" }
        let shoppingListItemEntity = coreDataModel.entities.first { $0.name == "ShoppingListItem" }
        
        XCTAssertNotNil(shoppingListEntity)
        XCTAssertNotNil(shoppingListItemEntity)
        
        let itemsRelationship = shoppingListEntity?.relationshipsByName["items"] as? NSRelationshipDescription
        let shoppingListRelationship = shoppingListItemEntity?.relationshipsByName["shoppingList"] as? NSRelationshipDescription
        
        XCTAssertNotNil(itemsRelationship)
        XCTAssertNotNil(shoppingListRelationship)
        
        // Verify inverse relationships are properly set up
        XCTAssertEqual(itemsRelationship?.inverseRelationship, shoppingListRelationship)
        XCTAssertEqual(shoppingListRelationship?.inverseRelationship, itemsRelationship)
        
        // Verify relationship properties
        XCTAssertTrue(itemsRelationship?.isToMany ?? false)
        XCTAssertFalse(shoppingListRelationship?.isToMany ?? true)
    }
}
