import Foundation
import RxCocoa
import RxSwift

public struct Style<T> {
    
    let object: T
}

public protocol Decorable: class {
    
    associatedtype DecorableType
    
    var style: Style<DecorableType> { get }
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

var stateDictionary = [Int: Any]()
var statesDictionary = [Int: Any]()
let statesDisposeBag = DisposeBag()
let statesObserver = AnyObserver<Int>.init { (event: Event<Int>) in
    guard let element = event.element else { return }
    objc_sync_enter(stateDictionary)
    stateDictionary[element] = nil
    objc_sync_exit(stateDictionary)
    objc_sync_enter(statesDictionary)
    statesDictionary[element] = nil
    objc_sync_exit(statesDictionary)
    print(stateDictionary.keys.count, statesDictionary.keys.count)
}

extension NSObject {
    
    func prepare() {
        if stateDictionary[address] == nil && statesDictionary[address] == nil {
            rx.deallocating
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .map({ [address] _ -> Int in
                    return address
                })
                .observeOn(MainScheduler.instance)
                .bind(to: statesObserver)
                .disposed(by: statesDisposeBag)
        }
    }
}

extension Decorable {
    
    var state: AnyHashable? {
        get {
            guard let object = self as? NSObject else { return nil }
            objc_sync_enter(stateDictionary)
            defer {
                objc_sync_exit(stateDictionary)
            }
            return stateDictionary[object.address] as? AnyHashable
        }
        set(value) {
            if let object = self as? NSObject {
                object.prepare()
                objc_sync_enter(stateDictionary)
                stateDictionary[object.address] = value
                objc_sync_exit(stateDictionary)
            }
            if let value = value, let decoration = states[value] {
                style.apply(decoration)
            }
        }
    }
    
    var states: [AnyHashable: Decoration<Self>] {
        get {
            guard let object = self as? NSObject else { return [:] }
            objc_sync_enter(statesDictionary)
            defer {
                objc_sync_exit(statesDictionary)
            }
            return statesDictionary[object.address] as? [AnyHashable: Decoration<Self>] ?? [:]
        }
        set(value) {
            if let object = self as? NSObject {
                object.prepare()
                objc_sync_enter(statesDictionary)
                statesDictionary[object.address] = value
                objc_sync_exit(statesDictionary)
            }
        }
    }
}
