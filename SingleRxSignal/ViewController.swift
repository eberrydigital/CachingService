//
//  ViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift

extension Observable {
    func flatMap(emitEventBeforeMap emitEvent: Bool, mapping: @escaping (E) -> Observable<E>) -> Observable<E> {
        return flatMap { (intermediate: E) -> Observable<E> in
            let mapped = mapping(intermediate)
            guard emitEvent else { return mapped }
            return .merge([.of(intermediate), mapped])
        }
    }
}

class ViewController: UIViewController {
    let bag = DisposeBag()
    let userService = UserService()
    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
    }
    
    func getUser() {
        getDataFromCacheAndOrBackend(emitExtraEventBeforeCachingDone: true).subscribe { guard case let .next(model) = $0 else { return }; print("Subscriber: `\(model)`") }.disposed(by: bag)
//        print("Fetching user")
//        userService.getUser(options: [.preventOnNextForFetched]).subscribe(onNext: {
//            print("subscriber: Got user: `\($0)`")
//        }, onError: {
//            print("subscriber: Error: `\($0)`")
//        }, onCompleted: {
//            print("subscriber: Completed")
//        }, onDisposed: {
//            print("subscriber: Disposed")
//        }).disposed(by: bag)
    }
    
    @IBAction func getPressed(_ sender: UIButton) {
        getUser()
    }
    
    @IBAction func clearCachePressed(_ sender: UIButton) {
        userService.cache.asyncDeleteValue(for: cacheKeyName) { _ in
            print("deleted")
        }
    }
    
    func getDataFromCacheAndOrBackend(emitExtraEventBeforeCachingDone emitExtra: Bool) -> Observable<Int> {
        return getDataFromBackend().flatMap(emitEventBeforeMap: emitExtra) { self.asyncSaveToCache(dataFromBackend: $0) }
    }
//    // using method `filterNil` from pod `RxOptional` below
//    func getDataFromCacheAndOrBackend(emitExtraEventBeforeCachingDone: Bool) -> Observable<Int> {
//        return getDataFromBackend().flatMap { (dataFromBackend: Int) -> Observable<Int> in
//            let maybeEmitExtraEvent: Observable<Int>? = emitExtraEventBeforeCachingDone ? .of(dataFromBackend) : nil
//            return Observable.of(
//                self.asyncSaveToCache(dataFromBackend: dataFromBackend),
//                maybeEmitExtraEvent
//            ).filterNil().merge()
//        }
//    }
    
    func getDataFromCacheAndOrBackend() -> Observable<Int> {
        return getDataFromBackend().flatMap { self.asyncSaveToCache(dataFromBackend: $0) }
    }
    
    func getDataFromBackend() -> Observable<Int> {
        return Observable.just(42).delay(2, scheduler: MainScheduler.instance)
            .do(onNext: { print("http response: `\($0)`") })
    }
    
    func asyncSaveToCache(dataFromBackend: Int) -> Observable<Int> {
        return Observable.just(dataFromBackend).delay(1, scheduler: MainScheduler.instance)
            .do(onNext: { print("cached: `\($0)`") })
    }
}

