//
//  PostPlayerReducer.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension PostPlayerViewModel {

  // swiftlint:disable:next cyclomatic_complexity
  static func reduce(state: State, action: Action) -> State {
    var newState = state
    switch action {

    case .updateProfile(let profile):
      newState.userProfile = profile

    case .updatePostsFeedState(let state):
      newState.postsFeedState = state

    case .updatePlayerMode(let playerMode):
      newState.playerMode = playerMode

    case .changeFavorite:
      guard let post = state.activePost, post.id.left != nil else { break }
      if !post.isFavorite, newState.canShowFavoriteAlert {
        newState.canShowFavoriteAlert = false
        newState.alert = .favorite
      }

    case .changePrivateness, .deletePost:
      newState.isLoading = true

    case .updatePost, .removePost:
      newState.isLoading = false

    case .setError(let error):
      newState.alert = .error(error.localizedDescription)
      newState.isLoading = false

    case .tryLoadMorePosts:
      newState.isUploadingMorePosts = true

    case .finishLoadMorePosts:
      newState.isUploadingMorePosts = false

    case .showMore:
      guard let post = state.activePost, post.author.id.rawValue == state.userProfile?.id.rawValue else {
        log.error("Tried to modify someone else's post")
        break
      }

      newState.alert = .moreInfo(isPrivatePost: post.isPrivate)

    case .dismissError:
      newState.alert = nil

    default:
      break
    }

    return newState
  }
}
