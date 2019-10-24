//
//  PostPlayerPlayersProviderMiddleware.swift
//  YazaKit
//
//  Created by Mykhailo Palchuk on 8/20/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension PostPlayerViewModel {
  static func makePlayersProviderMiddleware() -> Store.Middleware {
    return Store.makeMiddleware { _, getState, next, action in
      let oldState = getState()
      next(action)
      let state = getState()
      switch action {
      case .updatePostsFeedState:
        guard let index = state.activeIndex, oldState.activeIndex != index else {
          break
        }

        PlayersProvider.shared.setPosts(sources: state.posts.map { $0.assetSource }, activeIndex: index)

      default:
        break
      }
    }
  }
}
