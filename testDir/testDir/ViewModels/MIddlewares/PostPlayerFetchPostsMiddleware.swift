//
//  PostPlayerFetchPostsMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {

  static func makeFetchPostsMiddleware(
    postsProvider: PostsProvider,
    assetProvider: AssetProvider
  ) -> Store.Middleware {
    var disposable: Disposable?

    return Store.makeMiddleware { dispatch, getState, next, action in

      next(action)
      let state = getState()

      guard case Action.fetchContent = action, let id = state.place?.id else {
        return
      }

      disposable?.dispose()
      disposable = postsProvider.getPostsBy(placeID: id)
        .subscribe(
          onSuccess: { content in
            preloadVideoData(assetProvider: assetProvider, posts: content.posts)
            dispatch(.fetchContentSuccess(content))
            if !content.posts.isEmpty {
              dispatch(.didScrollPlayerTo(index: 0))
            }
          }, onError: { error in
            dispatch(.setError(error))
          }
        )
    }
  }
}

private func preloadVideoData(assetProvider: AssetProvider, posts: [NetworkPost]) {
  posts.forEach { post in
    AssetProvider.shared.addAsset(assetSource: post.assetSource)
  }
}
