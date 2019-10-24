//
//  VideoPlayerStore.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/14/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import AVFoundation.AVAsset

extension VideoPlayerViewModel {

  typealias Store = ReduxStore<State, Action>

  struct State {
    var postVideoInfo: [PostVideoInfo]
    var postsSource: PostsSource
    var activeVideoIndex: Int?
    // selectedIndex is used to inform outside about index of videos
    // it skip the initial index
    var selectedIndex: Int?
    var activeVideoDuration: Double?
    var isPlaying: Bool
    var isActionButtonVisible: Bool
    var manualVideoRate: Double?
    var progress: Double
  }

  enum Action {
    case updatePostVideoInfo([PostVideoInfo])
    case updateSource(PostsSource)
    case updateDuration(Double)
    case updateRate(Double)
    case selectPost(Int)
    case togglePlaying(on: Bool)
    case pause
    case tapLeft
    case tapRight
    case tapVideoPlayer
    case toggleActionButtonVisibility(on: Bool)
    case tapActionButton
  }
}
