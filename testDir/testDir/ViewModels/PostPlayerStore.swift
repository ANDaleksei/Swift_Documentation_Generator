//
//  PostPlayerStore.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension PostPlayerViewModel {

  typealias Store = ReduxStore<State, Action>

  struct State {
    var userProfile: Profile?
    var playerMode: PlayerMode
    var postsFeedState: PostsFeedState
    var isLastPage: Bool
    var tags: [PlaceTag]
    var isLoading: Bool
    var isUploadingMorePosts: Bool
    var canShowFavoriteAlert: Bool
    var alert: Alert?
  }

  enum Action {
    case fetchPosts
    case fetchNewPosts
    case updateProfile(Profile)
    case updatePostsFeedState(PostsFeedState)
    // action reflects posts feed facade update to player mode
    case updatePlayerMode(PlayerMode)
    case updatePost(Post)
    // action is used to set new player mode to posts feed facade
    case setPlayerMode(PlayerMode)
    case deselectPlace
    case removePost(NetworkPost.Identifier)
    case setError(Error)
    case tapItemAt(index: Int)
    case tryLoadMorePosts
    case finishLoadMorePosts
    case getDirection
    case sharePost
    case sendMessage(String)
    case showMore
    case changePrivateness
    case changeFavorite
    case deletePost
    case dismissError
  }
}

extension PostPlayerViewModel.State {

  var arePostsLoading: Bool {
    return postsFeedState.content.isLoading
  }

  var selectedMarkerID: MarkerIdentifier? {
    return postsFeedState.type.placeID
  }

  var posts: [NetworkPost] {
    return postsFeedState.content.posts ?? []
  }

  var activeIndex: Int? {
    return postsFeedState.activePostIndex
  }

  var activePost: NetworkPost? {
    guard let index = activeIndex else {
      return nil
    }
    guard posts.indices.contains(index) else {
      log.error(
        "Post Player. Posts doesn't contain index",
        details: [ "Posts": posts, "Index": index ]
      )
      return nil
    }
    return posts[index]
  }
}
