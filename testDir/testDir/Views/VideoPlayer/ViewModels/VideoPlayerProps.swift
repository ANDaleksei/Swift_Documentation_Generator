//
//  VideoPlayerProps.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/21/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension VideoPlayerViewModel {
  static func makeProps(state: State) -> VideoPlayerView.Props {
    return VideoPlayerView.Props(
      videoViewProps: makeVideoViewProps(state: state),
      isPlaying: state.isPlaying,
      isActionButtonVisible: state.isActionButtonVisible,
      timeText: makeTimeText(state: state),
      progress: makeProgress(state: state)
    )
  }

  private static func makeVideoViewProps(state: State) -> VideoView.Props {
    guard let index = state.activeVideoIndex else {
      return .empty
    }
    let assetSource = state.postVideoInfo[index].assetSource
    if state.isPlaying {
      return .playing(assetSource: assetSource, manualVideoRate: state.manualVideoRate)
    } else {
      return .paused(assetSource: assetSource, manualVideoRate: state.manualVideoRate)
    }
  }

  private static func makeTimeText(state: State) -> String {
    guard let duration = state.activeVideoDuration else { return "" }
    let time = Int(duration * state.progress)
    let minutes = String(format: "%02d", time / 60)
    let seconds = String(format: "%02d", time % 60)
    return "\(minutes):\(seconds)"
  }

  private static func makeProgress(state: State) -> Double {
    guard state.activeVideoDuration != 0 else { return 0.0 }
    return state.progress
  }
}
