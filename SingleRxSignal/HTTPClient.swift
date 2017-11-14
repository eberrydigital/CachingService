//
//  HTTPClient.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-10.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

struct HTTPClient: HTTPClientProtocol {}

protocol HTTPClientProtocol {
    func makeRequest<C>() -> Maybe<C> where C: Codable
}

extension HTTPClientProtocol {
    func makeRequest<C>() -> Maybe<C> where C: Codable {
        return Maybe.create { maybe in
            self.makeRequestOnBackground { (model: C?) in
                if let model = model {
                    maybe(.success(model))
                } else {
                    maybe(.error(MyError.httpError))
                }
            }
            
            return Disposables.create()
        }
    }
}

private extension HTTPClientProtocol {
    func makeRequestOnBackground<C>(done: @escaping (C?) -> Void) where C: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            self.performRequest(done: done)
        }
    }
    
    func performRequest<C>(done: @escaping (C?) -> Void) where C: Codable {
        delay(.http)
        threadTimePrint("Fetching from Backend...")
        let any: Any = C.self
        let model: C
        switch any {
        case is User.Type:
            model = User(name: randomName()) as! C
        case is Group.Type:
            model = Group(name: randomName()) as! C
        default: fatalError("non of the above")
        }
        DispatchQueue.main.async {
            done(model)
        }
    }
}
