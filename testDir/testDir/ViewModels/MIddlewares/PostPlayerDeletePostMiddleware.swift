//
//  PostPlayerDeletePostMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 5/3/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeDeletePostMiddleware(postsProvider: PostsProvider) -> Store.Middleware {
    var disposable: Disposable?

    return Store.makeMiddleware { dispatch, getState, next, action in
      let state = getState()

      switch action {
      case .deletePost:
        guard
          let post = state.activePost,
          post.author.id.rawValue == state.userProfile?.id.rawValue
        else {
          return
        }
        guard let postID = post.id.left, let markerID = state.selectedMarkerID else {
          return
        }

        next(action)

        disposable?.dispose()
        disposable = postsProvider.deletePost(postID: postID, markerID: markerID)
          .map(to: post.id)
          .map(Action.removePost)
          .catchError { return .just(Action.setError($0)) }
          .subscribe(onSuccess: dispatch)
      default:
        next(action)
      }
    }
  }
}
