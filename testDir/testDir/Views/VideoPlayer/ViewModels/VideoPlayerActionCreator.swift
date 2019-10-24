//
//  VideoPlayerActionCreator.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/14/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import RxSwift

extension VideoPlayerViewModel {

  final class ActionCreator {
    let actions: Observable<Action>
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

    // swiftlint:disable:next function_body_length
    init(inputs: Inputs, assetProvider: AssetProvider) {

      let postVideoInfo = inputs.postVideoInfo
        .share(replay: 1, scope: .whileConnected)

      let updatePostVideoInfo = postVideoInfo
        .map(Action.updatePostVideoInfo)

      let updateSource = inputs.postsSource
        .map(Action.updateSource)

      let updateRate = inputs.rate
        .map(Action.updateRate)

      let selectPost = inputs.selectedPost
        .map(Action.selectPost)

      let startPlaying = inputs.startPlaying
        .map(to: true)

      let stopPlaying = inputs.viewWillDisappear
        .map(to: false)

      let togglePlaying = Observable.merge(
          startPlaying,
          stopPlaying
        )
        .map(Action.togglePlaying)

      let pause = Observable.merge(
          inputs.pause,
          inputs.tapCenter
        )
        .map(to: Action.pause)

      let tapBackward = inputs.tapLeft
        .map(to: Action.tapLeft)

      let tapForward = Observable.merge(
          inputs.didFinishPlaying,
          inputs.tapRight
        )
        .map(to: Action.tapRight)

      let tapVideoPlayer = inputs.tapBottom
        .map(to: Action.tapVideoPlayer)

      let tapActionButton = inputs.tapActionButton
        .map(to: Action.tapActionButton)

      actions = Observable.merge(
        updatePostVideoInfo,
        updateSource,
        updateRate,
        selectPost,
        togglePlaying,
        pause,
        tapBackward,
        tapForward,
        tapVideoPlayer,
        tapActionButton
      )
    }
  }
}
