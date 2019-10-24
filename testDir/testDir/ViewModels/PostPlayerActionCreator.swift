//
//  PostPlayerActionCreator.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import RxSwift

extension PostPlayerViewModel {

  final class ActionCreator {
    let actions: Observable<Action>

    // swiftlint:disable:next function_body_length
    init(inputs: Inputs, dependencies: Dependencies) {

      let fetchNewPosts = Observable.merge(
          dependencies.appService.willEnterForeground,
          inputs.viewWillDisappear
        )
        .map(to: Action.fetchNewPosts)

      let updateProfile = dependencies.profileService.profile
        .ignoreNil()
        .map(Action.updateProfile)

      let updatePostsFeedState = dependencies.postsFeedProvider.observeActiveFeedState()
        .map(Action.updatePostsFeedState)

      let updatePlayerMode = dependencies.postsFeedProvider.playerMode
        .map(Action.updatePlayerMode)

      let setPlayerMode = inputs.setPlayerMode
        .map(Action.setPlayerMode)

      let deselectPlace = Observable.merge(
          inputs.tapClosePlaceFeed,
          inputs.tapCloseButton
        )
        .map(to: Action.deselectPlace)

      let tapItemAtIndex = inputs.tapPostWithIndex
        .map(Action.tapItemAt)

      let tryLoadMorePosts = inputs.isScrolledToEnd
        .map(to: Action.tryLoadMorePosts)

      let getDirection = inputs.tapGetDirection
        .map(to: Action.getDirection)

      let sendMessage = inputs.sendMessage
        .map(Action.sendMessage)

      let sharePost = inputs.tapSharePost
        .map(to: Action.sharePost)

      let moreInfo = inputs.tapMoreInfo
        .map(to: Action.showMore)

      let changePrivateness = inputs.changePrivateness
        .map(to: Action.changePrivateness)

      let changeFavoritness = inputs.tapFavorite
        .map(to: Action.changeFavorite)

      let deletePost = inputs.deletePost
        .map(to: Action.deletePost)

      let dismissError = inputs.dismissError
        .map(to: Action.dismissError)

      actions = Observable.merge(
        fetchNewPosts,
        updateProfile,
        updatePostsFeedState,
        updatePlayerMode,
        setPlayerMode,
        deselectPlace,
        tapItemAtIndex,
        tryLoadMorePosts,
        getDirection,
        sendMessage,
        sharePost,
        moreInfo,
        changePrivateness,
        changeFavoritness,
        deletePost,
        dismissError
      )
    }
  }
}
