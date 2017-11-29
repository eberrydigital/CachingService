//
//  MockedPersistingUserService.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal
import RxSwift

final class ExpectedUserResult: BaseExpectedResult<List<User>> {}

final class MockedPersistingUserService {
    let mockedUserHTTPClient: MockedUserHTTPClient
    let mockedUserCache: MockedCacheForUser
    
    init(httpClient: MockedUserHTTPClient, cache: MockedCacheForUser) {
        self.mockedUserHTTPClient = httpClient
        self.mockedUserCache = cache
    }
}

extension MockedPersistingUserService: Service {
    var httpClient: HTTPClientProtocol { return mockedUserHTTPClient }
}

extension MockedPersistingUserService: Persisting {
    var cache: AsyncCache { return mockedUserCache }
}

extension MockedPersistingUserService {
    convenience init(mocked: ExpectedUserResult) {
        self.init(
            httpClient: MockedUserHTTPClient(mockedEvent: mocked.httpEvent),
            cache: MockedCacheForUser(mockedEvent: mocked.cacheEvent)
        )
    }
}

extension MockedPersistingUserService {
    func assertElements(_ filter: QueryConvertible, removeEmptyArrays: Bool = true) -> [List<User>] {
        return materialized(filter: filter, removeEmptyArrays: removeEmptyArrays).elements
    }
    
    func materialized(_ filter: QueryConvertible, removeEmptyArrays: Bool = true) -> (elements: [List<User>], error: MyError?) {
        return materialized(filter: filter, removeEmptyArrays: removeEmptyArrays)
    }
}

extension MockedPersistingUserService {
    func assertElements(_ fetchFrom: FetchFrom = .default) -> [List<User>] {
        return materialized(fetchFrom).elements
    }
    
    func materialized(_ fetchFrom: FetchFrom = .default) -> (elements: [List<User>], error: MyError?) {
        return materialized(fetchFrom: fetchFrom)
    }
}
