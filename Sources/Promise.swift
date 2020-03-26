//
//  Promise.swift
//  Promise
//
//  Created by Green on 2020/3/24.
//  Copyright © 2020 Green. All rights reserved.
//

import Dispatch

enum PromiseError: Error {
    case invaild
}

public struct AsyncExecutor {
    public static let main = AsyncExecutor()
    public static let background = AsyncExecutor(qos: .default)
    
    private let queue: DispatchQueue
    
    public init(qos: DispatchQoS) {
        queue = DispatchQueue(label: "com.promise.async-executor", qos: qos)
    }
    
    private init() {
        queue = DispatchQueue.main
    }
    
    public func async(execute work: @escaping () -> Void) {
        queue.async(execute: work)
    }
}

final public class Promise<T> {
    private var result: Result<T, Error>?

    /// Resolves store the resolve who chains current instance.
    /// All the resolves will be inovked after sealing result.
    private var resolves: [(Result<T, Error>) -> Void] = []
    
    /// Executor will execute the resolve(s) at specific DispatchQueue.
    private var executor: AsyncExecutor?
    
    public init() {}
    public init(_ value: T) {
        result = .success(value)
    }

    public init(_ error: Error) {
        result = .failure(error)
    }

    public func fulfill(_ value: T) {
        seal(.success(value))
    }

    public func reject(_ error: Error) {
        seal(.failure(error))
    }

    private func seal(_ v: Result<T, Error>) {
        result = v
        let work = { self.resolves.forEach{ $0(v) } }
        guard let executor = executor else {
            work()
            return
        }
        executor.async(execute: work)
    }

    private func pipe(resolve: @escaping (Result<T, Error>) -> Void)  {
        guard let result = result else {
            resolves.append(resolve)
            return
        }
        let work = { resolve(result) }
        guard let executor = executor else {
            work()
            return
        }
        executor.async(execute: work)
    }

    @discardableResult
    func map<U>(_ transform: @escaping (T) throws -> U ) -> Promise<U> {
        let rp = Promise<U>()
        pipe { value in
            switch value {
                case .success(let element):
                    do {
                        let newElement = try transform(element)
                        rp.fulfill(newElement)
                    }
                    catch {
                        rp.reject(error)
                    }
                case .failure(let e):
                    rp.reject(e)
            }
        }
        return rp
    }

    @discardableResult
    public func then<E, U: Promise<E>>(_ body: @escaping (T) throws -> U) -> U {
        let rp = U()
        pipe {
            switch $0 {
            case .success(let value):
                do {
                    let inp = try body(value)
                    inp.pipe {
                        rp.seal($0)
                    }
                }
                catch {
                    rp.reject(error)
                }
            case .failure(let e):
                rp.reject(e)
            }
        }
        return rp
    }

    @discardableResult
    public func `catch`(_ body: @escaping (Error) -> Void) -> Promise<T> {
        let rp = Promise<T>()
        pipe {
            if case .failure(let error) = $0 {
                body(error)
            }
            rp.seal($0)
        }
        return rp
    }
    
    @discardableResult
    public func done(_ body: @escaping (T) -> Void) -> Promise<Void> {
        let rp = Promise<Void>()
        pipe {
            switch $0 {
            case .success(let value):
                body(value)
                rp.fulfill(())
            case .failure(let error):
                rp.reject(error)
            }
        }
        return rp
    }
}

extension Promise {
    @available(*, deprecated, message: "It's not thread-safe, will implement aysnc for it")
    @discardableResult
    public func dispatch(to executor: AsyncExecutor) -> Promise<T> {
        self.executor = executor
        return self
    }
}

func firstly<T>(executor: AsyncExecutor? = nil, body: () -> Promise<T>) -> Promise<T> {
    let p = body()
    if let executor = executor {
        p.dispatch(to: executor)
    }
    return p
}
