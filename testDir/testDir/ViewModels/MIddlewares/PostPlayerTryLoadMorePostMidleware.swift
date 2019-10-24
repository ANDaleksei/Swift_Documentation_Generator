//
//  PostPlayerTryLoadMorePostMidleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 7/3/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeTryLoadMorePostsMiddleware(dependencies: Dependencies) -> Store.Middleware {

    var disposable: Disposable?
    return Store.makeMiddleware { dispatch, getState, next, action in
      let state = getState()
      next(action)

      switch action {
      case .tryLoadMorePosts:
        guard !state.isLastPage && !state.isUploadingMorePosts else {
          return
        }
        disposable?.dispose()
        disposable = dependencies.postsFeedProvider.getMoreFeed()
          .map(to: Action.finishLoadMorePosts)
          .subscribe(onSuccess: dispatch)
      default:
        break
      }
    }
  }
}
