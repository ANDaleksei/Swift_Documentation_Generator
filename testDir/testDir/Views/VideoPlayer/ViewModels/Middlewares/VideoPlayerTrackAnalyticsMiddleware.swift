//
//  VideoPlayerTrackAnalyticsMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 18.10.2019.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension VideoPlayerViewModel {
  static func makeTrackAnalyticsMiddleware() -> Store.Middleware {

    return Store.makeMiddleware { _, getState, next, action in
      next(action)
      let state = getState()
      guard let index = state.activeVideoIndex else {
        return
      }
      let info = state.postVideoInfo[index]
      guard case .feed(let placeID) = state.postsSource else {
        return
      }

      switch action {
      case .pause, .tapActionButton:
        Analytics.shared.track(event: .postsPlayerClickVideoInPlayer(
            placeID: info.placeID,
            postID: info.postID.flatMap(NetworkPost.Identifier.left) ?? .right(.init(rawValue: "local")),
            isNewFeed: placeID == nil
          )
        )
      default:
        break
      }
    }
  }
}
