// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreData

/// A result builder that allows for declarative creation of Core Data models.
@resultBuilder
public struct CoreDataModelBuilder {
    public static func buildBlock(_ components: Entity...) -> [Entity] {
        components
    }
}

/// A result builder that allows for declarative creation of entity components.
@resultBuilder
public struct EntityBuilder {
    public static func buildBlock(_ components: EntityComponent...) -> [EntityComponent] {
        components
    }
    
    public static func buildExpression(_ expression: Attribute) -> EntityComponent {
        .attribute(expression)
    }
    
    public static func buildExpression(_ expression: Relationship) -> EntityComponent {
        .relationship(expression)
    }
}

/// Represents a component of an entity (either an attribute or a relationship).
public enum EntityComponent {
    case attribute(Attribute)
    case relationship(Relationship)
}

/// Represents a Core Data model that can be created using result builder syntax.
public struct CoreDataModel {
    private let model: Model
    
    /// Creates a new Core Data model using the provided builder.
    /// - Parameter builder: A closure that uses the result builder syntax to define entities.
    public init(@CoreDataModelBuilder _ builder: () -> [Entity]) {
        self.model = Model(entities: builder())
    }
    
    /// Creates a Core Data model configuration from the defined entities.
    /// - Returns: A `NSManagedObjectModel` instance representing the model.
    public func createModel() -> NSManagedObjectModel {
        model.createModel()
    }
}

/// Represents a Core Data entity.
public struct Entity {
    let name: String
    let attributes: [Attribute]
    let relationships: [Relationship]
    let isAbstract: Bool
    let managedObjectClass: AnyClass?
    
    public init(
        name: String,
        attributes: [Attribute],
        relationships: [Relationship] = [],
        isAbstract: Bool = false,
        managedObjectClass: AnyClass? = nil
    ) {
        self.name = name
        self.attributes = attributes
        self.relationships = relationships
        self.isAbstract = isAbstract
        self.managedObjectClass = managedObjectClass
    }
    
    func createEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.isAbstract = isAbstract
        
        // Set the managed object class if provided
        if let managedObjectClass = managedObjectClass {
            entity.managedObjectClassName = NSStringFromClass(managedObjectClass)
        }
        
        // Create attributes
        var attributes: [String: NSAttributeDescription] = [:]
        for attribute in self.attributes {
            let attr = NSAttributeDescription()
            attr.name = attribute.name
            attr.attributeType = attribute.type.coreDataType
            attr.isOptional = attribute.isOptional
            if let defaultValue = attribute.defaultValue {
                attr.defaultValue = defaultValue
            }
            attr.allowsExternalBinaryDataStorage = attribute.allowsExternalBinaryDataStorage
            attr.preservesValueInHistoryOnDeletion = attribute.preservesValueInHistoryOnDeletion
            attributes[attribute.name] = attr
        }
        
        // Create relationships
        var relationships: [String: NSRelationshipDescription] = [:]
        for relationship in self.relationships {
            let rel = NSRelationshipDescription()
            rel.name = relationship.name
            // destinationEntity will be set later
            rel.isOptional = relationship.isOptional
            rel.maxCount = relationship.isToMany ? 0 : 1
            rel.minCount = relationship.isOptional ? 0 : 1
            rel.deleteRule = relationship.deleteRule
            relationships[relationship.name] = rel
        }
        
        entity.properties = Array(attributes.values) + Array(relationships.values)
        return entity
    }
}

/// Extension to provide result builder syntax for Entity creation.
public extension Entity {
    /// Creates a new entity using result builder syntax.
    /// - Parameters:
    ///   - name: The name of the entity.
    ///   - isAbstract: Whether the entity is abstract.
    ///   - managedObjectClass: The NSManagedObject subclass to use for this entity.
    ///   - builder: A closure that uses the result builder syntax to define entity components.
    init(_ name: String, isAbstract: Bool = false, managedObjectClass: AnyClass? = nil, @EntityBuilder _ builder: () -> [EntityComponent]) {
        let components = builder()
        var attributes: [Attribute] = []
        var relationships: [Relationship] = []
        
        for component in components {
            switch component {
            case .attribute(let attribute):
                attributes.append(attribute)
            case .relationship(let relationship):
                relationships.append(relationship)
            }
        }
        
        self.init(name: name, attributes: attributes, relationships: relationships, isAbstract: isAbstract, managedObjectClass: managedObjectClass)
    }
}

/// Represents a Core Data attribute.
public struct Attribute {
    let name: String
    let type: AttributeType
    let isOptional: Bool
    let defaultValue: Any?
    let allowsExternalBinaryDataStorage: Bool
    let preservesValueInHistoryOnDeletion: Bool
    
    public init(
        name: String,
        type: AttributeType,
        isOptional: Bool = true,
        defaultValue: Any? = nil,
        allowsExternalBinaryDataStorage: Bool = false,
        preservesValueInHistoryOnDeletion: Bool = false
    ) {
        self.name = name
        self.type = type
        self.isOptional = isOptional
        self.defaultValue = defaultValue
        self.allowsExternalBinaryDataStorage = allowsExternalBinaryDataStorage
        self.preservesValueInHistoryOnDeletion = preservesValueInHistoryOnDeletion
    }
    
    /// Creates a string attribute.
    public static func string(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: String? = nil
    ) -> Attribute {
        Attribute(name: name, type: .string, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates an integer16 attribute.
    public static func integer16(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Int16? = nil
    ) -> Attribute {
        Attribute(name: name, type: .integer16, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates an integer32 attribute.
    public static func integer32(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Int32? = nil
    ) -> Attribute {
        Attribute(name: name, type: .integer32, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates an integer64 attribute.
    public static func integer64(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Int64? = nil
    ) -> Attribute {
        Attribute(name: name, type: .integer64, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a decimal attribute.
    public static func decimal(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Decimal? = nil
    ) -> Attribute {
        Attribute(name: name, type: .decimal, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a double attribute.
    public static func double(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Double? = nil
    ) -> Attribute {
        Attribute(name: name, type: .double, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a float attribute.
    public static func float(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Float? = nil
    ) -> Attribute {
        Attribute(name: name, type: .float, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a boolean attribute.
    public static func boolean(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Bool? = nil
    ) -> Attribute {
        Attribute(name: name, type: .boolean, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a date attribute.
    public static func date(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Date? = nil
    ) -> Attribute {
        Attribute(name: name, type: .date, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a binary attribute.
    public static func binary(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: Data? = nil,
        allowsExternalBinaryDataStorage: Bool = false
    ) -> Attribute {
        Attribute(
            name: name,
            type: .binary,
            isOptional: isOptional,
            defaultValue: defaultValue,
            allowsExternalBinaryDataStorage: allowsExternalBinaryDataStorage
        )
    }
    
    /// Creates a transformable attribute.
    public static func transformable<T>(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: T? = nil
    ) -> Attribute {
        Attribute(name: name, type: .transformable, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a UUID attribute.
    public static func uuid(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: UUID? = nil
    ) -> Attribute {
        Attribute(name: name, type: .uuid, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates a URI attribute.
    public static func uri(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: URL? = nil
    ) -> Attribute {
        Attribute(name: name, type: .uri, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    /// Creates an objectID attribute.
    public static func objectID(
        _ name: String,
        isOptional: Bool = true,
        defaultValue: NSManagedObjectID? = nil
    ) -> Attribute {
        Attribute(name: name, type: .objectID, isOptional: isOptional, defaultValue: defaultValue)
    }
    
    func createAttributeDescription() -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type.coreDataType
        attribute.isOptional = isOptional
        
        return attribute
    }
}

/// A result builder that allows for declarative configuration of attributes.
@resultBuilder
public struct AttributeBuilder {
    public static func buildBlock(_ components: AttributeComponent...) -> [AttributeComponent] {
        components
    }
    
    public static func buildExpression(_ expression: Validation) -> AttributeComponent {
        .validation(expression)
    }
    
    public static func buildExpression(_ expression: Constraint) -> AttributeComponent {
        .constraint(expression)
    }
    
    public static func buildExpression(_ expression: Bool) -> AttributeComponent {
        .optional(expression)
    }
}

/// Represents a component of an attribute configuration.
public enum AttributeComponent {
    case optional(Bool)
    case validation(Validation)
    case constraint(Constraint)
}

/// Represents the type of a Core Data attribute.
public enum AttributeType {
    case string
    case integer16
    case integer32
    case integer64
    case decimal
    case double
    case float
    case boolean
    case date
    case binary
    case transformable
    case uuid
    case uri
    case objectID
    
    var coreDataType: NSAttributeType {
        switch self {
        case .string: return .stringAttributeType
        case .integer16: return .integer16AttributeType
        case .integer32: return .integer32AttributeType
        case .integer64: return .integer64AttributeType
        case .decimal: return .decimalAttributeType
        case .double: return .doubleAttributeType
        case .float: return .floatAttributeType
        case .boolean: return .booleanAttributeType
        case .date: return .dateAttributeType
        case .binary: return .binaryDataAttributeType
        case .transformable: return .transformableAttributeType
        case .uuid: return .UUIDAttributeType
        case .uri: return .URIAttributeType
        case .objectID: return .objectIDAttributeType
        }
    }
}

/// Represents a validation rule for an attribute.
public struct Validation {
    let rule: ValidationRule
    
    public init(_ rule: ValidationRule) {
        self.rule = rule
    }
    
    func apply(to attribute: NSAttributeDescription) {
        rule.apply(to: attribute)
    }
}

/// Represents a validation rule type.
public enum ValidationRule {
    case email
    case range(ClosedRange<Int>)
    case custom((Any) -> Bool)
    
    func apply(to attribute: NSAttributeDescription) {
        // Implementation will be added
    }
}

/// Represents a constraint for an attribute.
public struct Constraint {
    let type: ConstraintType
    
    public init(_ type: ConstraintType) {
        self.type = type
    }
    
    func apply(to attribute: NSAttributeDescription) {
        type.apply(to: attribute)
    }
}

/// Represents a constraint type.
public enum ConstraintType {
    case unique
    
    func apply(to attribute: NSAttributeDescription) {
        // Implementation will be added
    }
}

/// Represents a Core Data relationship.
public struct Relationship {
    let name: String
    let destination: String
    let isOptional: Bool
    let isToMany: Bool
    let deleteRule: NSDeleteRule
    let inverse: String?
    
    public init(
        name: String,
        destination: String,
        isOptional: Bool = true,
        isToMany: Bool = false,
        deleteRule: NSDeleteRule = .nullifyDeleteRule,
        inverse: String? = nil
    ) {
        self.name = name
        self.destination = destination
        self.isOptional = isOptional
        self.isToMany = isToMany
        self.deleteRule = deleteRule
        self.inverse = inverse
    }
}

/// A result builder that allows for declarative configuration of relationships.
@resultBuilder
public struct RelationshipBuilder {
    public static func buildBlock(_ components: RelationshipComponent...) -> [RelationshipComponent] {
        components
    }
    
    public static func buildExpression(_ expression: String) -> RelationshipComponent {
        .inverse(expression)
    }
    
    public static func buildExpression(_ expression: Bool) -> RelationshipComponent {
        .optional(expression)
    }
    
    public static func buildExpression(_ expression: DeleteRule) -> RelationshipComponent {
        .deleteRule(expression)
    }
}

/// Represents a component of a relationship configuration.
public enum RelationshipComponent {
    case inverse(String)
    case optional(Bool)
    case deleteRule(DeleteRule)
}

/// Represents the type of a Core Data relationship.
public enum RelationshipType {
    case toOne
    case toMany
}

/// Represents a Core Data relationship delete rule.
public enum DeleteRule {
    case nullify
    case cascade
    case deny
    case noAction
    
    var coreDataDeleteRule: NSDeleteRule {
        switch self {
        case .nullify: return .nullifyDeleteRule
        case .cascade: return .cascadeDeleteRule
        case .deny: return .denyDeleteRule
        case .noAction: return .noActionDeleteRule
        }
    }
}

/// Represents a Core Data model.
public struct Model {
    let entities: [Entity]
    let version: Int
    
    public init(entities: [Entity], version: Int = 1) {
        self.entities = entities
        self.version = version
    }
    
    func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // Create entity descriptions
        var entityDescriptions: [String: NSEntityDescription] = [:]
        for entity in entities {
            let description = entity.createEntityDescription()
            entityDescriptions[entity.name] = description
        }
        
        // Set up relationships and their inverses
        for entity in entities {
            let description = entityDescriptions[entity.name]!
            for relationship in entity.relationships {
                let rel = description.relationshipsByName[relationship.name]!
                rel.destinationEntity = entityDescriptions[relationship.destination]
                
                // Set up inverse relationship if specified
                if let inverseName = relationship.inverse,
                   let destinationEntity = entityDescriptions[relationship.destination],
                   let inverseRelationship = destinationEntity.relationshipsByName[inverseName] {
                    rel.inverseRelationship = inverseRelationship
                    inverseRelationship.inverseRelationship = rel
                }
            }
        }
        
        model.entities = Array(entityDescriptions.values)
        return model
    }
}
