//
//  PostPlayerView+Constants.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/19/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension PostPlayerView {
  enum Constants {
    static let isSmallDevice = DeviceType.current.isSameOrSmaller(than: .iPhone5)
    static let isLessThanX = DeviceType.current.isSameOrSmaller(than: .iPhone6Plus)
    // Views' paddings
    static var scrollViewTopInset: CGFloat {
      return -noPostsOffset
    }
    static let headerTopPadding: CGFloat = isLessThanX ? 36 : 52
    static let lineTopPadding: CGFloat = 8
    static let lineHeight: CGFloat = 5
    static let contentInfoToLinePadding: CGFloat = 12
    static let contentInfoHeight: CGFloat = 18
    static var listOfPostsToHeaderPadding: CGFloat = isSmallDevice ? 8 : (isLessThanX ? 25 : 47)
    static let listOfPostsToContentInfoPadding: CGFloat = isLessThanX ? 12 : 16
    static let listOfPostsHeight: CGFloat = PostListView.Constants.itemHeight
    static let mainContainerToListOfPostsPadding: CGFloat = isLessThanX ? 8 : 22
    static let mainContainerToInteractionPadding: CGFloat = isSmallDevice ? 0 : (isLessThanX ? 8 : 16)
    static let interactionViewBottomPadding: CGFloat = isLessThanX ? 8 : 42
    static var playerCurtainHeight: CGFloat {
      return lineTopPadding
        + lineHeight
        + contentInfoToLinePadding
        + contentInfoHeight
        + listOfPostsToContentInfoPadding
        + listOfPostsHeight
        + mainContainerToListOfPostsPadding
        + YazaTabBarController.tabBarHeight
    }
    static var playerHeight: CGFloat {
      return UIScreen.main.bounds.height + openedPlayerOffset
    }
    static var emptyPlayerHeight: CGFloat {
      return UIScreen.main.bounds.height + noPostsOffset
    }
    // scroll view
    static let fullyVisibleOffset: CGFloat = 0
    static var openedPlayerOffset: CGFloat {
      return -(UIScreen.main.bounds.height
        - lineTopPadding
        - lineHeight
        - contentInfoToLinePadding
        - contentInfoHeight
        - listOfPostsToContentInfoPadding
        - listOfPostsHeight
        - mainContainerToListOfPostsPadding
        - UIScreen.main.bounds.width
        - mainContainerToInteractionPadding)
    }
    static var listOfPostsOffset: CGFloat {
      return -(UIScreen.main.bounds.height - playerCurtainHeight)
    }
    static var intermediateOffset: CGFloat {
      return noPostsOffset + PostListView.Constants.itemWidth / 2
    }
    static var intermediateCurtainHeight: CGFloat {
      return UIScreen.main.bounds.height + intermediateOffset
    }
    static var noPostsOffset: CGFloat {
      return -(UIScreen.main.bounds.height
        - lineTopPadding
        - lineHeight
        - contentInfoToLinePadding
        - contentInfoHeight
        - listOfPostsToContentInfoPadding
        - YazaTabBarController.tabBarHeight
      )
    }
    static var allOffsets: [CGFloat] {
      return [fullyVisibleOffset, openedPlayerOffset, listOfPostsOffset, intermediateOffset, noPostsOffset]
    }
    static var noPostsCurtainHeight: CGFloat {
      return UIScreen.main.bounds.height + noPostsOffset
    }
  }
}
