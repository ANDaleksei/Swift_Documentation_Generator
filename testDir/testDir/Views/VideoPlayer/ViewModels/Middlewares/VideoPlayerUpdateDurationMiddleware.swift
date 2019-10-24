//
//  VideoPlayerUpdateDurationMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 7/17/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension VideoPlayerViewModel {
  static func makeUpdateDurationMiddleware(assetProvider: AssetProvider) -> Store.Middleware {
    var disposable: Disposable?
    let backgroundScheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

    return Store.makeMiddleware { dispatch, getState, next, action in
      let index = getState().activeVideoIndex
      next(action)
      let newState = getState()
      guard let newIndex = newState.activeVideoIndex else {
        return
      }
      guard newIndex != index else {
        return
      }
      disposable?.dispose()
      disposable = Single.deferred {
          return assetProvider.getDurationOfAsset(assetSource: newState.postVideoInfo[newIndex].assetSource)
        }
        .subscribeOn(backgroundScheduler)
        .map(Action.updateDuration)
        .subscribe(onSuccess: dispatch)
    }
  }
}
