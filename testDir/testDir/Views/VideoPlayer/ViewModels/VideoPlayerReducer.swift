//
//  VideoPlayerReducer.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/14/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension VideoPlayerViewModel {

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  static func reduce(state: State, action: Action) -> State {
    var newState = state

    switch action {
    case .updatePostVideoInfo(let postVideoInfo):
      newState.postVideoInfo = postVideoInfo
      if !postVideoInfo.starts(with: state.postVideoInfo) {
        newState.activeVideoIndex = nil
        newState.selectedIndex = nil
        newState.activeVideoDuration = nil
        newState.manualVideoRate = nil
      }

    case .updateSource(let source):
      newState.postsSource = source

    case .updateDuration(let duration):
      newState.activeVideoDuration = duration

    case .updateRate(let rate):
      newState.progress = rate
      newState.manualVideoRate = nil

    case .selectPost(let index):
      guard newState.activeVideoIndex != index else {
        break
      }
      guard newState.postVideoInfo.indices.contains(index) else {
        break
      }
      newState.activeVideoIndex = index
      newState.selectedIndex = nil
      newState.activeVideoDuration = nil

    case .togglePlaying(on: let on):
      newState.isPlaying = on
      if !on {
        newState = resetPlayer(in: newState)
      }

    case .pause:
      newState.isPlaying = false
      newState.isActionButtonVisible = true

    case .tapVideoPlayer:
      if newState.isPlaying {
        newState.isActionButtonVisible.toggle()
      }

    case .tapLeft:
      guard let index = newState.activeVideoIndex else {
        break
      }
      // if video is played more than 3 seconds then reset it
      if let duration = newState.activeVideoDuration, newState.progress * duration > 3 {
        newState.progress = 0.0
        newState.manualVideoRate = 0.0
        break
      }
      // when user taps left we should choose next video as content is flipped
      newState = goForward(state: newState, index: index)

    case .tapRight:
      guard let index = newState.activeVideoIndex else {
        break
      }
      // when user taps right we should choose previous video as content is flipped
      newState = goBackward(state: newState, index: index)

    case .toggleActionButtonVisibility(on: let on):
      newState.isActionButtonVisible = on || !newState.isPlaying

    case .tapActionButton:
      newState.isPlaying = !newState.isPlaying
    }

    return newState
  }

  private static func resetPlayer(in state: State) -> State {
    var newState = state
    newState.progress = 0.0
    newState.manualVideoRate = 0.0
    newState.isActionButtonVisible = true
    newState.isPlaying = false

    return newState
  }

  private static func goForward(state: State, index: Int) -> State {
    var newState = state
    if index < newState.postVideoInfo.count - 1 {
      newState.activeVideoIndex = index + 1
      newState.selectedIndex = newState.activeVideoIndex
      newState.activeVideoDuration = nil
    } else {
      newState = resetPlayer(in: newState)
    }
    return newState
  }

  private static func goBackward(state: State, index: Int) -> State {
    var newState = state
    if index > 0 {
      newState.activeVideoIndex = index - 1
      newState.selectedIndex = newState.activeVideoIndex
      newState.activeVideoDuration = nil
    } else {
      newState = resetPlayer(in: newState)
    }
    return newState
  }

  enum Constants {
    static let rewindTime: Double = 5.0
  }
}
