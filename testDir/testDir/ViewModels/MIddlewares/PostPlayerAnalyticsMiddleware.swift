//
//  PostPlayerAnalyticsMiddleware.swift
//  YazaKit
//
//  Created by Arthur Myronenko on 6/4/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension PostPlayerViewModel {
  // swiftlint:disable:next cyclomatic_complexity
  static func makeAnalyticsMiddleware() -> Store.Middleware {
    return Store.makeMiddleware { _, getState, next, action in
      next(action)
      let state = getState()

      switch action {
      case .tapItemAt(let index):
        guard state.posts.indices.contains(index) else {
          return
        }
        let post = state.posts[index]
        Analytics.shared.track(event: .postsPlayerClickVideo(
            placeID: post.shareablePost?.place.id,
            postID: post.id,
            position: index,
            isNewFeed: state.selectedMarkerID == nil
          )
        )

      case .setPlayerMode(let mode):
        trackAnalytic(
          oldPlayerMode: state.playerMode,
          newPlayerMode: mode,
          isNewFeed: state.selectedMarkerID == nil
        )

      case .deselectPlace:
        Analytics.shared.track(event: .postsPlayerClosePlayerViaCross())

      case .changeFavorite:
        guard let post = state.activePost, post.id.left != nil else {
          return
        }
        if !post.isFavorite {
          Analytics.shared.track(event: .postsPlayerClickBookmark(isNewFeed: state.selectedMarkerID == nil))
        }

      case .sendMessage:
        guard state.activePost?.shareablePost != nil else {
          break
        }
        guard let yazer = state.activePost?.author else {
          break
        }
        guard yazer.id.rawValue != state.userProfile?.id.rawValue else {
          break
        }
        Analytics.shared.track(event: .postsPlayerSendReply(isNewFeed: state.selectedMarkerID == nil))

      case .sharePost:
        guard state.activePost?.shareablePost != nil else {
          break
        }
        Analytics.shared.track(event: .postsPlayerClickShare(isNewFeed: state.selectedMarkerID == nil))

      default:
        return
      }
    }
  }
}

private func trackAnalytic(oldPlayerMode: PlayerMode, newPlayerMode: PlayerMode, isNewFeed: Bool) {
  if !oldPlayerMode.isPlayerActive && newPlayerMode == .opened {
    Analytics.shared.track(event: .postsPlayerSwipeFeedUp(isNewFeed: isNewFeed))
  }
  if oldPlayerMode.isPlayerActive && !newPlayerMode.isPlayerActive {
    Analytics.shared.track(event: .postsPlayerSwipePlayerDown(isNewFeed: isNewFeed))
  }
  if oldPlayerMode != .fullScreen && newPlayerMode == .fullScreen {
    Analytics.shared.track(event: .postsPlayerSwipeOpenedPlayerUp(isNewFeed: isNewFeed))
  }
}
