//
//  VideoPlayerResultMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 7/23/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension VideoPlayerViewModel {
  static func makeResultMiddleware() -> (Store.Middleware, Observable<Result>) {
    let resultSubject = PublishSubject<Result>()

    let middleware = Store.makeMiddleware { _, getState, next, action in
      let state = getState()
      next(action)

      switch action {
      case .tapRight:
        guard let index = state.activeVideoIndex else {
          break
        }
        if index == 0 {
          resultSubject.onNext(.endPlaying)
        }
      default:
        break
      }
    }

    return (middleware, resultSubject.asObservable())
  }
}
