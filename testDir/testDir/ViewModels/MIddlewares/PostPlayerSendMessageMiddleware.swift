//
//  PostPlayerSendMessageMiddleware.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/13/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift

extension PostPlayerViewModel {
  static func makeSendMessageMiddleware(dependencies: Dependencies) -> Store.Middleware {

    var disposable: Disposable?

    return Store.makeMiddleware { _, getState, next, action in
      next(action)
      let state = getState()

      switch action {
      case .sendMessage(let message):
        guard let post = state.activePost?.shareablePost else {
          break
        }
        guard let yazer = state.activePost?.author else {
          break
        }
        guard yazer.id.rawValue != state.userProfile?.id.rawValue else {
          break
        }
        disposable?.dispose()
        disposable = dependencies.chatsListener.createNewChat(name: "", participants: [yazer])
          .flatMap { chat -> Single<Void> in
            let sharingPost = NewPostMessage(
              post: SharedPost(post: post),
              chatID: chat.id,
              date: dependencies.dateService.getCurrentAdjustedDate()
            )
            let newMessage = NewMessage(
              date: dependencies.dateService.getCurrentAdjustedDate(),
              body: message,
              chatID: chat.id
            )
            let messageProvider = dependencies.messageProviderFabric(chat)
            messageProvider.share(post: sharingPost, message: newMessage)
            return .just(())
          }
          .subscribe()

      default: break
      }
    }
  }
}
