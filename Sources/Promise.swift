//
//  Promise.swift
//  Promise
//
//  Created by Green on 2020/3/24.
//  Copyright © 2020 Green. All rights reserved.
//

import Dispatch
extension DispatchQueue {
    public static let pm_background = DispatchQueue(label: "com.promise.default.background.qeueu", qos: .default)
}

enum PromiseError: Error {
    case invaild
}

final public class Promise<T> {
    private var result: Result<T, Error>?

    /// Resolves store the resolve who chains current instance.
    /// All the resolves will be inovked after sealing result.
    private var resolves: [(Result<T, Error>) -> Void] = []
    
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
        resolves.forEach{ $0(v) }
    }

    private func pipe(resolve: @escaping (Result<T, Error>) -> Void)  {
        guard let result = result else {
            resolves.append(resolve)
            return
        }
        resolve(result)
    }

    @discardableResult
    func map<U>(on: DispatchQueue = .pm_background, _ transform: @escaping (T) throws -> U ) -> Promise<U> {
        let rp = Promise<U>()
        pipe { value in
            switch value {
                case .success(let element):
                    on.async {
                        do {
                            let newElement = try transform(element)
                            rp.fulfill(newElement)
                        }
                        catch {
                            rp.reject(error)
                        }
                    }
                case .failure(let e):
                    rp.reject(e)
            }
        }
        return rp
    }

    @discardableResult
    public func then<E, U: Promise<E>>(on: DispatchQueue = .pm_background, _ body: @escaping (T) throws -> U) -> U {
        let rp = U()
        pipe {
            switch $0 {
            case .success(let value):
                on.async {
                    do {
                        let inp = try body(value)
                        inp.pipe {
                            rp.seal($0)
                        }
                    }
                    catch {
                        rp.reject(error)
                    }
                }
            case .failure(let e):
                rp.reject(e)
            }
        }
        return rp
    }

    @discardableResult
    public func `catch`(on: DispatchQueue = .main, _ body: @escaping (Error) -> Void) -> Promise<T> {
        let rp = Promise<T>()
        pipe { result in
            on.async {
                if case .failure(let error) = result {
                    body(error)
                }
            }
            rp.seal(result)
        }
        return rp
    }
    
    @discardableResult
    public func done(on: DispatchQueue = .main, _ body: @escaping (T) -> Void) -> Promise<Void> {
        let rp = Promise<Void>()
        pipe { result in
            on.async {
                switch result {
                case .success(let value):
                    body(value)
                    rp.fulfill(())
                case .failure(let error):
                    rp.reject(error)
                }
            }
        }
        return rp
    }
}

func firstly<T, P: Promise<T>>(body: () -> P) -> P {
    body()
}
