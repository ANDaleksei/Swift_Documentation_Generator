//
//  VideoPlayerTimeMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/14/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension VideoPlayerViewModel {
  static func makeTimerMiddleware() -> Store.Middleware {
    var tapVideoPlayerDisposable: Disposable?

    return Store.makeMiddleware { dispatch, _, next, action in
      next(action)

      switch action {
      case .tapVideoPlayer, .tapActionButton, .togglePlaying:
        tapVideoPlayerDisposable?.dispose()
        tapVideoPlayerDisposable = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
          .take(1)
          .map(to: Action.toggleActionButtonVisibility(on: false))
          .subscribe(onNext: dispatch)

      default: break
      }
    }
  }
}
