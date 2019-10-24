//
//  PostPlayerResultiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeResultMiddleware(dependencies: Dependencies) -> (Store.Middleware, Observable<Result>) {
    let resultSubject = PublishSubject<Result>()

    let middleware = Store.makeMiddleware { _, getState, next, action in
      let state = getState()
      next(action)

      switch action {

      case .getDirection:
        guard let place = state.activePost?.shareablePost?.place else {
          break
        }
        resultSubject.onNext(.getDirection(place.location))

      default:
        break
      }
    }

    return (middleware, resultSubject.asObservable())
  }
}
