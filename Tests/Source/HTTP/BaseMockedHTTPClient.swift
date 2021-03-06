//
//  BaseMockedHTTPClient.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

@testable import CachingService
import RxSwift
import SwiftyBeaver

class BaseMockedHTTPClient<ValueType: Codable & Equatable> {
    var mockedEvent: MockedEvent<ValueType>
    
    let mockedReachability: MockedReachabilityService
    private let delay: RxTimeInterval
    
    init(
        reachability: MockedReachabilityService = MockedReachabilityService(),
        mockedEvent: MockedEvent<ValueType>,
        delay: RxTimeInterval = 0.02
        ) {
        self.mockedReachability = reachability
        self.mockedEvent = mockedEvent
        self.delay = delay
    }
}
extension BaseMockedHTTPClient: HTTPClientProtocol {


    func makeFireForgetRequest(request: Router) -> Observable<()> {
        fatalError("not impl")
    }
    var reachability: ReachabilityServiceConvertible { return mockedReachability }

    func makeRequest(request: Router) -> Observable<()> { fatalError("not impl") }
    func download<Downloadable>(request: Router) -> Observable<Downloadable> where Downloadable : DataConvertible { fatalError("not impl") }
    func uploadImage<UploadResponse>(_ image: UIImage, router: Router, jsonDecoder: JSONDecoder = JSONDecoder()) -> Observable<UploadResponse> where UploadResponse : Decodable { fatalError("not impl") }

    func makeRequest<Model>(request: Router, jsonDecoder: JSONDecoder = JSONDecoder()) -> Observable<Model?> where Model: Codable {
        log.verbose("Start, mocked request against path: `\(request.path)`")
        return reachability.status.flatMap { (reachabilityStatus: ReachabilityStatus) -> Observable<Model?> in
            guard reachabilityStatus != .none else { return .error(ServiceError.APIError.NetworkError.noNetwork) }
            return self._makeRequest(request: request)
        }
    }
}

private extension BaseMockedHTTPClient {

    func _makeRequest<Model>(request: Router) -> Observable<Model?> where Model: Codable {
        return Observable.create { observer in
            switch self.mockedEvent {
            case .error(let error):
                observer.onError(error)
            case .valueOrEmpty(let valueOrEmpty):
                switch valueOrEmpty {
                case .empty: observer.onNext(nil)
                case .value(let value): observer.onNext(value as! Model)
                }
                observer.onCompleted()
            }
            return Disposables.create()
            }.delay(delay, scheduler: MainScheduler.instance)
    }
}

extension BaseMockedHTTPClient {
    var mockedValue: ValueType? {
        return mockedEvent.value
    }
}
