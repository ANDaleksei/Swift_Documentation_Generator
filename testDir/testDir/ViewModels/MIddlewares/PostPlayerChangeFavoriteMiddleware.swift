//
//  PostPlayerChangeFavoriteMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 7/2/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeChangeFavoriteMiddleware(dependencies: Dependencies) -> Store.Middleware {
    var disposable: Disposable?

    return Store.makeMiddleware { dispatch, getState, next, action in
      let state = getState()

      switch action {
      case .changeFavorite:
        guard let post = state.activePost, let postID = post.id.left else { return }
        next(action)
        if !post.isFavorite {
          try? dependencies.storage.store(bool: false, forKey: Keys.favoriteAlert)
        }

        disposable?.dispose()
        disposable = dependencies.postsProvider.changePostFavorite(postID: postID, isFavorite: !post.isFavorite)
          .subscribe(onError: { dispatch(Action.setError($0)) })
      default:
        next(action)
      }
    }
  }
}
