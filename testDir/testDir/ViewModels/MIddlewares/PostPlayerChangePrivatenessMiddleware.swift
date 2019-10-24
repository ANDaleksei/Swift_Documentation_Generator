//
//  PostPlayerChangePrivatenessMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 5/3/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeChangePrivatenessMiddleware(postsProvider: PostsProvider) -> Store.Middleware {
    var disposable: Disposable?

    return Store.makeMiddleware { dispatch, getState, next, action in
      let state = getState()

      switch action {
      case .changePrivateness:
        guard
          let post = state.activePost,
          post.author.id.rawValue == state.userProfile?.id.rawValue
        else {
          return
        }
        guard let postID = post.id.left else {
          log.error(
            "Tried to change privateness of local post",
            details: ["Post": post, "Profile": state.userProfile as Any]
          )
          return
        }

        next(action)

        disposable?.dispose()
        disposable = postsProvider.changePostPrivateness(postID: postID, isPrivate: !post.isPrivate)
          .asObservable()
          .ignoreNil()
          .map(Action.updatePost)
          .catchError { return .just(Action.setError($0)) }
          .subscribe(onNext: dispatch)
      default:
        next(action)
      }
    }
  }
}
