//
//  PostPlayerView+Scrolling.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/19/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

extension PostPlayerView: UIScrollViewDelegate {

  private enum OffsetZone {
    case fullScreen
    case opened
    case listOfPosts
    case intermediate

    init(offset: CGFloat) {
      if offset > Constants.openedPlayerOffset {
        self = .fullScreen
      } else if offset > Constants.listOfPostsOffset {
        self = .opened
      } else if offset > Constants.intermediateOffset {
        self = .listOfPosts
      } else {
        self = .intermediate
      }
    }
  }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  func scrollViewWillEndDragging(
    _ scrollView: UIScrollView,
    withVelocity velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
    endEditing(true)
    let fullyVisibleOffset = Constants.fullyVisibleOffset
    let openedPlayerOffset = Constants.openedPlayerOffset
    let listOfPostsPlayerOffset = Constants.listOfPostsOffset
    let intermediatePlayerOffset = Constants.intermediateOffset
    let noPostsPlayerOffset = Constants.noPostsOffset
    let velocitySign = ScrollVelocitySign(velocity: velocity.y)
    let offset = scrollView.contentOffset.y
    let offsetZone = OffsetZone(offset: offset)
    let isFeedEmpty = renderedProps?.isFeedEmpty ?? true
    switch (offsetZone, velocitySign) {
    // fullscreen zone
    case (.fullScreen, .positive):
      targetContentOffset.pointee.y = fullyVisibleOffset
    case (.fullScreen, .zero):
      let isCloseToTop = offset > (fullyVisibleOffset + openedPlayerOffset) / 2
      targetContentOffset.pointee.y = isCloseToTop ? fullyVisibleOffset : openedPlayerOffset
    case (.fullScreen, .negative):
      targetContentOffset.pointee.y = openedPlayerOffset
    // openned zone
    case (.opened, .positive):
      targetContentOffset.pointee.y = openedPlayerOffset
    case (.opened, .zero):
      let bottomOffset = isFeedEmpty ? noPostsPlayerOffset : listOfPostsPlayerOffset
      let isCloseToTop = offset > (openedPlayerOffset + bottomOffset) / 2
      targetContentOffset.pointee.y = isCloseToTop ? openedPlayerOffset : bottomOffset
    case (.opened, .negative):
      targetContentOffset.pointee.y = isFeedEmpty ? noPostsPlayerOffset : listOfPostsPlayerOffset
    // list of posts zone
    case (.listOfPosts, .positive):
      let topOffset = isFeedEmpty ? openedPlayerOffset : listOfPostsPlayerOffset
      targetContentOffset.pointee.y = topOffset
    case (.listOfPosts, .zero):
      let topOffset = isFeedEmpty ? openedPlayerOffset : listOfPostsPlayerOffset
      let bottomOffset = isFeedEmpty ? noPostsPlayerOffset : intermediatePlayerOffset
      let isCloseToTop = offset > (topOffset + bottomOffset) / 2
      targetContentOffset.pointee.y = isCloseToTop ? topOffset : bottomOffset
    case (.listOfPosts, .negative):
      targetContentOffset.pointee.y = isFeedEmpty ? noPostsPlayerOffset : intermediatePlayerOffset
    // intermediate zone
    case (.intermediate, .positive):
      let topOffset = isFeedEmpty ? openedPlayerOffset : intermediatePlayerOffset
      targetContentOffset.pointee.y = topOffset
    case (.intermediate, .zero):
      guard isFeedEmpty else {
        targetContentOffset.pointee.y = intermediatePlayerOffset
        break
      }
      let topOffset = isFeedEmpty ? openedPlayerOffset : intermediatePlayerOffset
      let isCloseToMiddle = offset > (topOffset + noPostsPlayerOffset) / 2
      targetContentOffset.pointee.y = isCloseToMiddle ? openedPlayerOffset : noPostsPlayerOffset
    case (.intermediate, .negative):
      targetContentOffset.pointee.y = isFeedEmpty ? noPostsPlayerOffset : intermediatePlayerOffset
    }

    if targetContentOffset.pointee.y == Constants.openedPlayerOffset {
      activeModeSubject.onNext(.opened)
    } else if targetContentOffset.pointee.y == Constants.listOfPostsOffset {
      activeModeSubject.onNext(.listOfPosts)
    } else if targetContentOffset.pointee.y == Constants.fullyVisibleOffset {
      activeModeSubject.onNext(.fullScreen)
    } else if targetContentOffset.pointee.y == Constants.noPostsOffset && isFeedEmpty {
      activeModeSubject.onNext(.noPosts)
    } else if targetContentOffset.pointee.y == Constants.intermediateOffset {
      activeModeSubject.onNext(.intermediate)
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.y
    let openedPlayerOffset = Constants.openedPlayerOffset
    let bottomOffset = getBottomOffset()
    mainContainerView.alpha = (offset - bottomOffset) / (openedPlayerOffset - bottomOffset)
    setupHeaderAlpha(offset: offset)
    setupContentInfoAlpha(offset: offset)
    setCornerRadius(offset: offset)
    lineView.alpha = offset >= Constants.fullyVisibleOffset ? 0 : 1
    guard scrollView.isDragging else {
      return
    }
    let isFeedEmpty = renderedProps?.isFeedEmpty ?? true
    let topOffset = isFeedEmpty ? Constants.openedPlayerOffset : Constants.fullyVisibleOffset
    if offset > topOffset {
      scrollView.setContentOffset(.init(x: 0, y: topOffset), animated: false)
    } else if offset < bottomOffset {
      scrollView.setContentOffset(.init(x: 0, y: bottomOffset), animated: false)
    }
  }

  private func setCornerRadius(offset: CGFloat) {
    backgroundView.roundCornersContinuosly(
      radius: offset >= Constants.fullyVisibleOffset ? 0 : 30,
      corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    )
  }

  private func setupHeaderAlpha(offset: CGFloat) {
    let maxOffset = Constants.fullyVisibleOffset
    let minOffset = (maxOffset + Constants.openedPlayerOffset) / 2
    guard offset < maxOffset else {
      headerView.alpha = 1.0
      return
    }
    guard offset > minOffset else {
      headerView.alpha = 0.0
      return
    }
    let difference = maxOffset - minOffset
    headerView.alpha = (offset - minOffset) / difference
  }

  private func setupContentInfoAlpha(offset: CGFloat) {
    let minOffset = Constants.openedPlayerOffset
    let maxOffset = (Constants.fullyVisibleOffset + minOffset) / 2
    guard offset < maxOffset else {
      contentInfoView.alpha = 0.0
      return
    }
    guard offset > minOffset else {
      contentInfoView.alpha = 1.0
      return
    }
    let difference = maxOffset - minOffset
    contentInfoView.alpha = 1 - (offset - minOffset) / difference
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    beginScrollingSubject.onNext(())
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      endScrollingSubject.onNext(())
    }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    endScrollingSubject.onNext(())
    let bottomOffset = getBottomOffset()
    let isFeedEmpty = renderedProps?.isFeedEmpty ?? true
    if scrollView.contentOffset.y < bottomOffset {
      activeModeSubject.onNext(isFeedEmpty ? .noPosts : .intermediate)
    }
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    endScrollingSubject.onNext(())
  }

  private func getBottomOffset() -> CGFloat {
    let isFeedEmpty = renderedProps?.isFeedEmpty ?? true
    return isFeedEmpty
      ? PostPlayerView.Constants.noPostsOffset
      : PostPlayerView.Constants.intermediateOffset
  }
}
