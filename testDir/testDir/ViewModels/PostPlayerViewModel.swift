//
//  PostPlayerViewModel.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/7/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import RxSwift

final class PostPlayerViewModel {

  struct Inputs {
    let viewWillAppear: Observable<Void>
    let viewWillDisappear: Observable<Void>
    let setPlayerMode: Observable<PlayerMode>
    let tapCloseButton: Observable<Void>
    let tapClosePlaceFeed: Observable<Void>
    let tapPostWithIndex: Observable<Int>
    let isScrolledToEnd: Observable<Void>
    let tapGetDirection: Observable<Void>
    let sendMessage: Observable<String>
    let tapSharePost: Observable<Void>
    let tapFavorite: Observable<Void>
    let tapMoreInfo: Observable<Void>
    let changePrivateness: Observable<Void>
    let deletePost: Observable<Void>
    let dismissError: Observable<Void>
  }

  struct Outputs {
    let props: Observable<PostPlayerViewController.Props>
    let changes: Observable<Void>
    let route: Observable<Route>
    let interruptPlaybackTrigger: Observable<Void>
    let result: Observable<Result>
  }

  struct Dependencies {
    let storage: Storage
    let appService: AppService
    let profileService: ProfileService
    let locationService: LocationService
    let postsFeedProvider: PostsFeedFacade
    let postsProvider: PostsProvider
    let chatsListener: ChatsListener
    let messageProviderFabric: (Chat) -> MessagesProvider
    let dateService: DateService
    let assetProvider: AssetProvider
  }

  enum Alert: Equatable {
    case error(String)
    case moreInfo(isPrivatePost: Bool)
    case favorite
  }

  enum Result {
    case getDirection(Location)
  }

  enum Route {
    case showShareList(SharePostInfo)
  }

  private let dependencies: Dependencies
  private let scheduler: SchedulerType

  init(dependencies: Dependencies, scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInitiated)) {
    self.dependencies = dependencies
    self.scheduler = scheduler
  }

  // swiftlint:disable:next function_body_length
  func makeOutputs(from inputs: Inputs) -> Outputs {

    let initialState = makeInitialState(storage: dependencies.storage)

    let readPostMiddleware = PostPlayerViewModel.makeReadPostMiddleware(
      postsProvider: dependencies.postsProvider
    )
    let changePrivatenessMiddleware = PostPlayerViewModel.makeChangePrivatenessMiddleware(
      postsProvider: dependencies.postsProvider
    )
    let changeFavoriteMiddleware = PostPlayerViewModel.makeChangeFavoriteMiddleware(
      dependencies: dependencies
    )
    let deletePostMiddleware = PostPlayerViewModel.makeDeletePostMiddleware(
      postsProvider: dependencies.postsProvider
    )
    let (resultMiddleware, result) = PostPlayerViewModel.makeResultMiddleware(dependencies: dependencies)
    let (routeMiddleware, route) = PostPlayerViewModel.makeRouteMiddleware()
    let (playbackInterruptionMiddleware, interruptPlaybackTrigger) =
      PostPlayerViewModel.makePlaybackInterruptionMiddleware()
    let sendMessageMiddleware = PostPlayerViewModel.makeSendMessageMiddleware(dependencies: dependencies)
    let tapPostMiddleware = PostPlayerViewModel.makeTapPostMiddleware(postsFeedProvider: dependencies.postsFeedProvider)
    let tryLoadMorePostsMiddleware = PostPlayerViewModel.makeTryLoadMorePostsMiddleware(dependencies: dependencies)
    let manageFeedMiddleware = PostPlayerViewModel.makeManageFeedMiddleware(postsFeedFacade: dependencies.postsFeedProvider)
    let playersProviderMiddleware = PostPlayerViewModel.makePlayersProviderMiddleware()
    let analyticsMiddleware = PostPlayerViewModel.makeAnalyticsMiddleware()

    let store = Store(
      initialState: initialState,
      reducer: PostPlayerViewModel.reduce,
      middlewares: [
        readPostMiddleware,
        changePrivatenessMiddleware,
        changeFavoriteMiddleware,
        deletePostMiddleware,
        resultMiddleware,
        routeMiddleware,
        sendMessageMiddleware,
        tapPostMiddleware,
        tryLoadMorePostsMiddleware,
        manageFeedMiddleware,
        playbackInterruptionMiddleware,
        playersProviderMiddleware,
        analyticsMiddleware
      ]
    )

    let actionCreator = ActionCreator(inputs: inputs, dependencies: dependencies)

    let stateChanges = actionCreator.actions
      .do(onNext: store.dispatch)
      .toVoid()

    let state = store.state.share(replay: 1, scope: .whileConnected)

    let props = state
      .observeOn(scheduler)
      .map(PostPlayerViewModel.makeProps)

    return Outputs(
      props: props,
      changes: stateChanges,
      route: route,
      interruptPlaybackTrigger: interruptPlaybackTrigger,
      result: result
    )
  }

  private func makeInitialState(storage: Storage) -> State {
    return State(
      userProfile: nil,
      playerMode: .noPosts,
      postsFeedState: PostsFeedState(type: .new, content: .loading, activePostID: nil),
      isLastPage: false,
      tags: [],
      isLoading: false,
      isUploadingMorePosts: false,
      canShowFavoriteAlert: (try? storage.getBool(forKey: Keys.favoriteAlert)) ?? true,
      alert: nil
    )
  }

  enum Keys {
    static var favoriteAlert: String = "PostPlayerViewModel.favoriteAlert"
  }
}
