//
//  PostPlayerRouteMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 4/2/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeRouteMiddleware() -> (Store.Middleware, Observable<Route>) {
    let routeSubject = PublishSubject<Route>()

    let middleware = Store.makeMiddleware { _, getState, next, action in
      next(action)
      let state = getState()

      switch action {
      case .sharePost:
        guard let post = state.activePost?.shareablePost else {
          break
        }
        let sharePostInfo = SharePostInfo(post: post, source: .feed(isNewFeed: state.selectedMarkerID == nil))
        routeSubject.onNext(.showShareList(sharePostInfo))

      default:
        break
      }
    }

    return (middleware, routeSubject.asObservable())
  }
}
