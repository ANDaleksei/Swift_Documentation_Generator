//
//  PostPlayerReadPostMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 4/12/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {

  static func makeReadPostMiddleware(postsProvider: PostsProvider) -> Store.Middleware {

    var disposable: Disposable?

    return Store.makeMiddleware { _, getState, next, action in

      let state = getState()
      let posts = state.posts
      next(action)

      switch action {
      case .updatePostsFeedState(let feedState):
        guard let index = feedState.activePostIndex, state.posts.indices.contains(index) else {
          break
        }

        guard !posts[index].isRead else {
          break
        }

        disposable?.dispose()
        disposable = postsProvider.read(post: posts[index])
          .subscribe()

      default:
        break
      }
    }
  }
}
