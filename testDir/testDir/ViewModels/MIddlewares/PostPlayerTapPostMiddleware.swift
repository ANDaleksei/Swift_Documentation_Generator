//
//  PostPlayerTapPostMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 7/3/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeTapPostMiddleware(postsFeedProvider: PostsFeedFacade) -> Store.Middleware {
    return Store.makeMiddleware { _, getState, next, action in
      next(action)
      let state = getState()

      switch action {
      case .tapItemAt(let index):
        guard state.posts.indices.contains(index) else {
          return
        }
        postsFeedProvider.setActivePostID(state.posts[index].id)

      default:
        break
      }
    }
  }
}
