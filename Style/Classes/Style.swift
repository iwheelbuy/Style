import Foundation

public struct Style<T> {
    
    let object: T
}

public protocol Decorable: class {
    
    associatedtype DecorableType
    
    var style: Style<DecorableType> { get set }
}

extension NSObject: Decorable {
    
    var address: Int {
        return unsafeBitCast(self, to: Int.self)
    }
}

public typealias Decoration<T> = (T) -> Void

public extension Decorable {
    
    static func decoration(closure: @escaping Decoration<Self>) -> Decoration<Self> {
        return closure
    }
}

public extension Style where T: Decorable {
    
    @discardableResult
    func apply(_ decorations: Decoration<T>...) -> Style<T> {
        decorations.forEach { (decoration) in
            decoration(object)
        }
        return self
    }
    
    @discardableResult
    static func +(style: Style<T>, decoration: @escaping Decoration<T>) -> Style<T> {
        style.apply(decoration)
        return style
    }
    
    @discardableResult
    func prepare(state: AnyHashable, decoration: @escaping Decoration<T>) -> Style<T> {
        object.states[state] = decoration
        guard state == object.state else { return self }
        object.state = state
        return self
    }
    
    @discardableResult
    func prepare(states: AnyHashable..., decoration: @escaping Decoration<T>) -> Style<T> {
        for state in states {
            object.states[state] = decoration
            guard state == object.state else { continue }
            object.state = state
        }
        return self
    }
    
    var state: AnyHashable? {
        get {
            return object.state
        }
        set(value) {
            object.state = value
        }
    }
}

public func +<T:Decorable>(lhs: @escaping Decoration<T>, rhs: @escaping Decoration<T>) -> Decoration<T> {
    return { (value: T) -> Void in
        lhs(value)
        rhs(value)
    }
}

public extension Decorable {
    
    var style: Style<Self> {
        get {
            return Style(object: self)
        }
        set {
            //
        }
    }
}

struct StyleFrameworkRuntimeKeys {
    
    static var state = "\(#file)+\(#line)"
    static var states = "\(#file)+\(#line)"
}

var stateDictionary = [Int: Any]()
var statesDictionary = [Int: Any]()

extension Decorable {
    
    var state: AnyHashable? {
        get {
            guard let object = self as? NSObject else { return nil }
            return stateDictionary[object.address] as? AnyHashable
        }
        set(value) {
            if let object = self as? NSObject {
                stateDictionary[object.address] = value
            }
            if let value = value, let decoration = states[value] {
                style.apply(decoration)
            }
        }
    }
    
    var states: [AnyHashable: Decoration<Self>] {
        get {
            guard let object = self as? NSObject else { return [:] }
            guard let dictionary = statesDictionary[object.address] as? [AnyHashable: Decoration<Self>] else { return [:] }
            return dictionary
        }
        set(value) {
            if let object = self as? NSObject {
                statesDictionary[object.address] = value
            }
        }
    }
}
