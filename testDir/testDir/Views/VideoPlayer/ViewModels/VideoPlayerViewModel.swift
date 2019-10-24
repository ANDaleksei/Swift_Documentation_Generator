//
//  VideoPlayerViewModel.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/12/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import RxSwift
import AVFoundation.AVAsset

final class VideoPlayerViewModel {

  typealias PostsSource = VideoPlayerViewController.Source

  struct Inputs {
    let viewWillDisappear: Observable<Void>
    let postVideoInfo: Observable<[PostVideoInfo]>
    let postsSource: Observable<PostsSource>
    let selectedPost: Observable<Int>
    let rate: Observable<Double>
    let startPlaying: Observable<Void>
    let pause: Observable<Void>
    let tapLeft: Observable<Void>
    let tapRight: Observable<Void>
    let tapCenter: Observable<Void>
    let tapBottom: Observable<Void>
    let tapActionButton: Observable<Void>
    let didFinishPlaying: Observable<Void>
  }

  struct Outputs {
    let props: Observable<VideoPlayerView.Props>
    let activePostIndex: Observable<Int>
    let result: Observable<Result>
    let stateChanges: Observable<Void>
  }

  enum Result {
    case endPlaying
  }

  private let assetProvider: AssetProvider
  private let scheduler: SchedulerType

  init(assetProvider: AssetProvider, scheduler: SchedulerType = MainScheduler.instance) {
    self.assetProvider = assetProvider
    self.scheduler = scheduler
  }

  func makeOutputs(from inputs: Inputs) -> Outputs {

    let initialState = makeInitialState()

    let timeMiddleware = VideoPlayerViewModel.makeTimerMiddleware()
    let updateDurationMiddleware = VideoPlayerViewModel.makeUpdateDurationMiddleware(assetProvider: assetProvider)
    let trackAnalyticsMiddleware = VideoPlayerViewModel.makeTrackAnalyticsMiddleware()
    let (resultMiddleware, result) = VideoPlayerViewModel.makeResultMiddleware()

    let store = Store(
      initialState: initialState,
      reducer: VideoPlayerViewModel.reduce,
      middlewares: [timeMiddleware, updateDurationMiddleware, trackAnalyticsMiddleware, resultMiddleware]
    )

    let actionCreator = ActionCreator(inputs: inputs, assetProvider: assetProvider)

    let stateChanges = actionCreator.actions
      .do(onNext: store.dispatch)
      .toVoid()

    let state = store.state.share(replay: 1, scope: .whileConnected)

    let props = state.map(VideoPlayerViewModel.makeProps)

    let activePostIndex = state.map { $0.selectedIndex }
      .distinctUntilChanged()
      .ignoreNil()

    return Outputs(
      props: props,
      activePostIndex: activePostIndex,
      result: result,
      stateChanges: stateChanges
    )
  }

  private func makeInitialState() -> State {
    return State(
      postVideoInfo: [],
      postsSource: .local,
      activeVideoIndex: nil,
      selectedIndex: nil,
      activeVideoDuration: nil,
      isPlaying: false,
      isActionButtonVisible: true,
      manualVideoRate: nil,
      progress: 0.0
    )
  }
}
