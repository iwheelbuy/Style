import Foundation
import RxCocoa
import RxSwift

public struct Style<T> {
    
    let object: T
}

public protocol Decorable: class {
    
    associatedtype DecorableType
    
    var style: Style<DecorableType> { get set }
}

extension NSObject: Decorable {}

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
        let holder = object.holder
        holder.states[state] = decoration
        if state == holder.state {
            object.style.apply(decoration)
        }
        return self
    }
    
    @discardableResult
    func prepare(states: AnyHashable..., decoration: @escaping Decoration<T>) -> Style<T> {
        let holder = object.holder
        for state in states {
            holder.states[state] = decoration
        }
        if let state = holder.state, states.contains(state) {
            object.style.apply(decoration)
        }
        return self
    }
    
    var state: AnyHashable? {
        get {
            return object.holder.state
        }
        set(value) {
            object.holder.state = value
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

final class Holder<T:Decorable> {
    
    var state = Optional<AnyHashable>.none
    var states = [AnyHashable: Decoration<T>]()
}

private var STYLE_FRAMEWORK_HOLDER_ASSOCIATION_KEY: UInt8 = 0

extension Decorable {
    
    var holder: Holder<Self> {
        get {
            if let holder = objc_getAssociatedObject(self, &STYLE_FRAMEWORK_HOLDER_ASSOCIATION_KEY) as? Holder<Self> {
                print("get")
                return holder
            } else {
                print("set")
                let holder = Holder<Self>()
                let policy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                objc_setAssociatedObject(self, &STYLE_FRAMEWORK_HOLDER_ASSOCIATION_KEY, holder, policy)
                return holder
            }
        }
    }
}
