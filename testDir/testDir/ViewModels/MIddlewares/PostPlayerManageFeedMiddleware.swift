//
//  PostPlayerManageFeedMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/8/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeManageFeedMiddleware(postsFeedFacade: PostsFeedFacade) -> Store.Middleware {

    return Store.makeMiddleware { _, getState, next, action in
      next(action)
      let state = getState()

      switch action {

      case .fetchNewPosts:
        postsFeedFacade.updateNewFeed()

      case .setPlayerMode(let mode):
        postsFeedFacade.setPlayerMode(mode)
        guard mode == .opened && state.activePost == nil else {
          break
        }
        guard let postID = state.posts.first?.id else {
          break
        }
        postsFeedFacade.setActivePostID(postID)

      case .deselectPlace:
        postsFeedFacade.selectPlace(with: nil)

      case .updatePostsFeedState:
        guard state.selectedMarkerID != nil, state.posts.count > 0, state.activePost == nil else {
          break
        }
        postsFeedFacade.setActivePostID(state.posts[min(state.posts.count - 1, 3)].id)

      default: break
      }
    }
  }
}
