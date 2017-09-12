import Foundation

public struct Style<T> {
    
    let object: T
}

public protocol Alterable: class {
    
    associatedtype AlterType
    
    var style: Style<AlterType> { get set }
}

extension NSObject: Alterable {
    
    var address: Int {
        return unsafeBitCast(self, to: Int.self)
    }
}

public typealias Change<T> = (T) -> Void

public extension Alterable {
    
    static func change(closure: @escaping Change<Self>) -> Change<Self> {
        return closure
    }
}

public extension Style where T: Alterable {
    
    @discardableResult
    func apply(_ changes: Change<T>...) -> Style<T> {
        changes.forEach { (change) in
            change(object)
        }
        return self
    }
    
    @discardableResult
    static func +(style: Style<T>, change: @escaping Change<T>) -> Style<T> {
        style.apply(change)
        return style
    }
    
    @discardableResult
    func prepare(state: AnyHashable, change: @escaping Change<T>) -> Style<T> {
        object.states[state] = change
        guard state == object.state else { return self }
        object.state = state
        return self
    }
    
    @discardableResult
    func prepare(states: AnyHashable..., change: @escaping Change<T>) -> Style<T> {
        for state in states {
            object.states[state] = change
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

public func +<T:Alterable>(lhs: @escaping Change<T>, rhs: @escaping Change<T>) -> Change<T> {
    return { (value: T) -> Void in
        lhs(value)
        rhs(value)
    }
}

public extension Alterable {
    
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

extension Alterable {
    
    var state: AnyHashable? {
        get {
            guard let object = self as? NSObject else { return nil }
            return stateDictionary[object.address] as? AnyHashable
        }
        set(value) {
            if let object = self as? NSObject {
                stateDictionary[object.address] = value
            }
            if let value = value, let change = states[value] {
                style.apply(change)
            }
        }
    }
    
    var states: [AnyHashable: Change<Self>] {
        get {
            guard let object = self as? NSObject else { return [:] }
            guard let dictionary = statesDictionary[object.address] as? [AnyHashable: Change<Self>] else { return [:] }
            return dictionary
        }
        set(value) {
            if let object = self as? NSObject {
                statesDictionary[object.address] = value
            }
        }
    }
}
