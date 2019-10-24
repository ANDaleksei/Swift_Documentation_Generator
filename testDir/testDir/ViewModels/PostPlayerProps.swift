//
//  PostPlayerProps.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import AVFoundation

extension PostPlayerViewModel {

  fileprivate static var datesCache = NSCache<NSDate, NSString>()

  static func makeProps(from state: State) -> PostPlayerViewController.Props {
    return PostPlayerViewController.Props(
      viewProps: makeViewProps(state: state),
      playerMode: state.playerMode,
      isLoading: state.isLoading,
      alert: state.alert
    )
  }

  private static func makeViewProps(state: State) -> PostPlayerView.Props {
    return PostPlayerView.Props(
      playerMode: state.playerMode,
      isFeedEmpty: state.posts.isEmpty,
      isNewFeed: state.selectedMarkerID == nil,
      headerProps: makeHeaderProps(state: state),
      contentInfoProps: makeContentInfoProps(state: state),
      postListProps: makePostListProps(state: state),
      interactionViewProps: makeInteractionViewProps(state: state),
      infoViewProps: makeInfoViewProps(state: state),
      emptyFeedProps: makeEmptyFeedProps(state: state)
    )
  }

  private static func makeHeaderProps(state: State) -> PostPlayerHeaderView.Props {
    return PostPlayerHeaderView.Props(
      iconName: state.activePost?.placePreview.iconName ?? "no image",
      placeName: state.activePost?.placePreview.name ?? "No name",
      placeAddress: state.activePost?.placePreview.address ?? "Unknown address",
      tagsText: state.activePost?.tags.compactMap { "#\($0)" }.joined(separator: " ") ?? ""
    )
  }

  private static func makeContentInfoProps(state: State) -> PostPlayerContentInfoView.Props {
    return PostPlayerContentInfoView.Props(
      feedSourceText: makeFeedSourceText(state: state),
      isCloseButtonVisible: state.selectedMarkerID != nil && state.playerMode != .fullScreen
    )
  }

  private static func makeFeedSourceText(state: State) -> NSAttributedString {
    guard state.selectedMarkerID != nil else {
      return NSAttributedString(string: "New from around the world")
    }

    guard !state.postsFeedState.content.isLoading else {
      return NSAttributedString(string: "Video is loading")
    }

    let attributedText = NSMutableAttributedString()
    attributedText.append(NSAttributedString(string: "Video from "))
    let imageAttachment = NSTextAttachment()
    imageAttachment.image = UIImage.littlePin
    attributedText.append(NSAttributedString(attachment: imageAttachment))
    let placeName = state.posts.first?.placePreview.name ?? "Yaza"
    attributedText.append(NSAttributedString(string: " " + placeName))
    return attributedText
  }

  private static func makePostListProps(state: State) -> PostListView.Props {
    let postsProps = state.posts.map { post in
      return PostPreviewCollectionViewCell.Props(
        avatar: post.thumbnailSource,
        isPost: true,
        authorName: post.author.fullName,
        placeName: post.placePreview.name,
        isPlaceNameHidden: state.selectedMarkerID != nil,
        secondaryText: makeDateName(from: post.recordDate),
        isRead: post.isRead,
        isActive: state.activePost?.id == post.id,
        isPrivate: post.isPrivate,
        isEnable: true,
        uploadingPostID: post.id.right
      )
    }
    let realItems = postsProps.map(PostListView.CellType.post)
    let stubbedItems = (0...5).map { _ in PostListView.CellType.stubbed }
    return PostListView.Props(
      posts: state.arePostsLoading ? stubbedItems : realItems,
      isCollectionViewInteractive: !state.arePostsLoading,
      activePostIndex: state.activeIndex,
      selectedPlace: state.selectedMarkerID
    )
  }

  private static func makeInteractionViewProps(state: State) -> PostPlayerInteractionView.Props {
    let authorName = state.activePost?.author.fullName
    let placeholder = authorName.flatMap { "Reply to \($0)..." } ?? "Send message..."
    return PostPlayerInteractionView.Props(
      isViewActive: state.playerMode == .fullScreen && !DeviceType.current.isSameOrSmaller(than: .iPhone6Plus),
      isFavorite: state.activePost?.isFavorite ?? false,
      messagePlaceholder: placeholder,
      isSendingMessageAvailable: state.activePost?.author.id.rawValue != state.userProfile?.id.rawValue
    )
  }

  private static func makeInfoViewProps(state: State) -> PostPlayerInfoView.Props {
    let authorName = state.activePost?.author.fullName
    return PostPlayerInfoView.Props(text: "Your reply was sent to \(authorName ?? "")")
  }

  private static func makeEmptyFeedProps(state: State) -> PostPlayerEmptyFeedView.Props {
    guard state.playerMode == .opened else {
      return .hidden
    }
    if state.selectedMarkerID == nil && state.posts.isEmpty {
      return .feedIsEmpty
    }
    return .hidden
  }
}

private func makeDateName(from date: Date) -> String {
  let components = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: date)
  guard let dateWithoutTime = Calendar.current.date(from: components) else {
    return ""
  }

  if let cached = PostPlayerViewModel.datesCache.object(forKey: dateWithoutTime as NSDate) {
    return cached as String
  } else {
    let result: String = {
      if Calendar.current.isDateInToday(date) {
        return YazaFormatters.dayTimeFormatter.string(for: date) ?? ""
      } else if Calendar.current.isDateInYesterday(date) {
        return "yesterday"
      } else {
        return YazaFormatters.shortDayMonthFormatter.string(for: date) ?? ""
      }
    }()
    PostPlayerViewModel.datesCache.setObject(result as NSString, forKey: dateWithoutTime as NSDate)
    return result
  }
}
