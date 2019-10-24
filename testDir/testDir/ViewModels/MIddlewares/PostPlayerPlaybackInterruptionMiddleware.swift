//
//  PostPlayerInterruptPlaybackMiddleware.swift
//  YazaKit
//
//  Created by Arthur Mironenko on 19.08.2019.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makePlaybackInterruptionMiddleware() -> (Store.Middleware, Observable<Void>) {
    let interruptionSubject = PublishSubject<Void>()
    let middleware = Store.makeMiddleware { _, getState, next, action in
      let oldState = getState()
      next(action)
      let newState = getState()

      if oldState.alert == nil && newState.alert != nil {
        interruptionSubject.onNext(Void())
      }

      switch action {
      case .getDirection:
        interruptionSubject.onNext(Void())
      default:
        break
      }
    }

    return (middleware, interruptionSubject.asObservable())
  }
}
