//
//  PostPlayerView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/7/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

// swiftlint:disable file_length

import UIKit
import RxSwift

// swiftlint:disable:next type_body_length
final class PostPlayerView: UIView {
  struct Props: Equatable {
    let playerMode: PlayerMode
    let isFeedEmpty: Bool
    let isNewFeed: Bool
    let headerProps: PostPlayerHeaderView.Props
    let contentInfoProps: PostPlayerContentInfoView.Props
    let postListProps: PostListView.Props
    let interactionViewProps: PostPlayerInteractionView.Props
    let infoViewProps: PostPlayerInfoView.Props
    let emptyFeedProps: PostPlayerEmptyFeedView.Props
  }

  private let scrollView = UIScrollView()
  let backgroundView = UIView()
  private let overlayView = VisualEffectView(blurPrefereneces: BlurPreferences(
    radius: 4,
    colorTint: .black,
    colorTintAlpha: 0.6
  ))
  let lineView = UIView()
  let headerView = PostPlayerHeaderView()
  let contentInfoView = PostPlayerContentInfoView()
  let postListView: PostListView
  private(set) var mainContainerView = UIView()
  let interactionView = PostPlayerInteractionView(mode: .solid)
  fileprivate let messageInputView = MessageInputView()
  fileprivate let infoView = PostPlayerInfoView()
  private let emptyFeedView = PostPlayerEmptyFeedView()
  let interactionViewIsActiveSubject = PublishSubject<Bool>()
  let sendMessageSubject = PublishSubject<String>()
  let beginScrollingSubject = PublishSubject<Void>()
  let endScrollingSubject = PublishSubject<Void>()
  let activeModeSubject = PublishSubject<PlayerMode>()
  private let disposeBag = DisposeBag()
  private var activeMode: PlayerMode?
  private(set) var renderedProps: Props?
  // constraints
  private var messageInputViewBottomConstraint: NSLayoutConstraint!

  private let dismissKeyboardGesture = UITapGestureRecognizer(target: nil, action: nil)

  init(postsQueue: PostsQueue) {
    self.postListView = PostListView(postsQueue: postsQueue)
    super.init(frame: .init(x: 0, y: 0, width: 192, height: 227))
    setup()
    setupKeyboard()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func getNewestPostView() -> UIView? {
    return postListView.getNewestPostView()
  }

  // swiftlint:disable:next function_body_length
  private func setup() {
    // configure scroll view
    scrollView.delegate = self
    scrollView.scrollsToTop = false
    scrollView.backgroundColor = UIColor.clear
    scrollView.decelerationRate = .fast
    scrollView.bounces = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInset.top = Constants.scrollViewTopInset
    scrollView.contentInsetAdjustmentBehavior = .never
    addSubview(scrollView, withEdgeInsets: .zero)

    // configure background view
    backgroundView.clipsToBounds = true
    backgroundView.backgroundColor = .containerLogin
    backgroundView.roundCornersContinuosly(radius: 30, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
    backgroundView.layer.addShadow(opacitiy: 0.05, radius: 10, offset: CGSize(width: 0, height: 1))
    scrollView.addSubview(backgroundView, constraints: [
      backgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      backgroundView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
      backgroundView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])

    // configure line view
    lineView.backgroundColor = .buttonsBackground
    lineView.layer.cornerRadius = 2.5
    backgroundView.addSubview(lineView, constraints: [
      lineView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Constants.lineTopPadding),
      lineView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
      lineView.widthAnchor.constraint(equalToConstant: 36),
      lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight)
    ])

    // configure header view
    backgroundView.addSubview(headerView, constraints: [
      headerView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.headerTopPadding),
      headerView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
      headerView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
    ])

    // configure content info view
    backgroundView.addSubview(contentInfoView, constraints: [
      contentInfoView.topAnchor.constraint(
        equalTo: lineView.bottomAnchor,
        constant: Constants.contentInfoToLinePadding
      ).prioritised(as: .defaultLow),
      contentInfoView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
      contentInfoView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
      contentInfoView.heightAnchor.constraint(equalToConstant: Constants.contentInfoHeight)
    ])

    // configure list post view
    backgroundView.addSubview(postListView, constraints: [
      postListView.topAnchor.constraint(
        equalTo: contentInfoView.bottomAnchor,
        constant: Constants.listOfPostsToContentInfoPadding
      ).prioritised(as: .defaultHigh),
      postListView.topAnchor.constraint(
        greaterThanOrEqualTo: headerView.bottomAnchor,
        constant: Constants.listOfPostsToHeaderPadding
      ),
      postListView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
      postListView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
      postListView.heightAnchor.constraint(equalToConstant: Constants.listOfPostsHeight)
    ])

    // configure main container view
    backgroundView.addSubview(mainContainerView, constraints: [
      mainContainerView.topAnchor.constraint(
        equalTo: postListView.bottomAnchor,
        constant: Constants.mainContainerToListOfPostsPadding
      ),
      mainContainerView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
      mainContainerView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
      mainContainerView.heightAnchor.constraint(equalTo: mainContainerView.widthAnchor)
    ])

    // configure empty feed view
    emptyFeedView.isUserInteractionEnabled = false
    backgroundView.addSubview(emptyFeedView, constraints: [
      emptyFeedView.topAnchor.constraint(equalTo: contentInfoView.bottomAnchor, constant: 84),
      emptyFeedView.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])

    // configure overlay view
    overlayView.isHidden = true
    addSubview(overlayView, withEdgeInsets: .zero)

    // configure player interaction view
    interactionView.onDidTapReply = { [weak self] in
      self?.trackOpenReplyMessageEvent()
      self?.messageInputView.activateTextField()
    }
    if !DeviceType.current.isSameOrSmaller(than: .iPhone6Plus) {
      // we add subview to whole view becuase when this view is inside scroll view
      // then scroll view's offset becomes weird
      addSubview(interactionView, constraints: [
        interactionView.topAnchor.constraint(
          equalTo: mainContainerView.bottomAnchor,
          constant: Constants.mainContainerToInteractionPadding
        ),
        interactionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        interactionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        interactionView.bottomAnchor.constraint(
          lessThanOrEqualTo: backgroundView.bottomAnchor,
          constant: -Constants.interactionViewBottomPadding
        )
      ])
    }

    // configure info view
    infoView.isUserInteractionEnabled = false
    infoView.alpha = 0.0
    addSubview(infoView, constraints: [
      infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      infoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -34),
      infoView.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])

    // configure message input view
    messageInputView.isHidden = true
    messageInputView.delegate = self
    messageInputViewBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: bottomAnchor)
    // we add subview to whole view becuase when this view is inside scroll view
    // then scroll view's offset becomes weird
    addSubview(messageInputView, constraints: [
      messageInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      messageInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      messageInputViewBottomConstraint
    ])
  }

  private func setupKeyboard() {
    Keyboard.change
      .filter { [weak self] _ in
        self?.currentFirstResponder() != nil
      }
      .map { change -> CGFloat in
        switch change.notificationName {
        case UIResponder.keyboardWillHideNotification: return 0
        default: return change.frame.height
        }
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: animateMessageView)
      .disposed(by: disposeBag)
  }

  func render(props: Props) {
    headerView.render(props: props.headerProps)
    contentInfoView.render(props: props.contentInfoProps)
    postListView.render(props: props.postListProps)
    if props.playerMode != activeMode {
      activeMode = props.playerMode
      setMode(props.playerMode)
    }
    interactionView.render(props: props.interactionViewProps)
    infoView.render(props: props.infoViewProps)
    emptyFeedView.render(props: props.emptyFeedProps)
    renderedProps = props
  }

  func addMainView(_ mainView: UIView) {
    mainContainerView.subviews.forEach { $0.removeFromSuperview() }
    mainContainerView.addSubview(mainView, withEdgeInsets: .zero)
  }

  func activateMessageField() {
    trackOpenReplyMessageEvent()
    messageInputView.activateTextField()
  }

  private func setMode(_ mode: PlayerMode) {
    switch mode {
    case .fullScreen:
      showFullScreen()
    case .opened:
      showOpened()
    case .listOfPosts:
      showListOfPost()
    case .intermediate:
      showIntermediate()
    case .noPosts:
      showNoPosts()
    }
  }

  private func showFullScreen() {
    if !scrollView.isDecelerating {
      if (Constants.allOffsets.filter { $0 != Constants.fullyVisibleOffset }).contains(scrollView.contentOffset.y) {
        beginScrollingSubject.onNext(())
      }
      scrollView.setContentOffset(.init(x: 0, y: Constants.fullyVisibleOffset), animated: true)
    }
  }

  private func showOpened() {
    if !scrollView.isDecelerating {
      if (Constants.allOffsets.filter { $0 != Constants.openedPlayerOffset }).contains(scrollView.contentOffset.y) {
        beginScrollingSubject.onNext(())
      }
      scrollView.setContentOffset(.init(x: 0, y: Constants.openedPlayerOffset), animated: true)
    }
  }

  private func showListOfPost() {
    if !scrollView.isDecelerating {
      if (Constants.allOffsets.filter { $0 != Constants.listOfPostsOffset }).contains(scrollView.contentOffset.y) {
        beginScrollingSubject.onNext(())
      }
      scrollView.setContentOffset(.init(x: 0, y: Constants.listOfPostsOffset), animated: true)
    }
  }

  private func showIntermediate() {
    if !scrollView.isDecelerating {
      if (Constants.allOffsets.filter { $0 != Constants.intermediateOffset }).contains(scrollView.contentOffset.y) {
        beginScrollingSubject.onNext(())
      }
      scrollView.setContentOffset(.init(x: 0, y: Constants.intermediateOffset), animated: true)
    }
  }

  private func showNoPosts() {
    if !scrollView.isDecelerating {
      if (Constants.allOffsets.filter { $0 != Constants.noPostsOffset }).contains(scrollView.contentOffset.y) {
        beginScrollingSubject.onNext(())
      }
      scrollView.setContentOffset(.init(x: 0, y: Constants.noPostsOffset), animated: true)
    }
  }

  private func animateMessageView(_ keyboardHeight: CGFloat) {
    layoutIfNeeded()
    messageInputViewBottomConstraint.constant = keyboardHeight > 0
      ? -(keyboardHeight + 10)
      : 0
    overlayView.isHidden = keyboardHeight <= 0
    messageInputView.isHidden = keyboardHeight <= 0
    layoutIfNeeded()
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard overlayView.isHidden else {
      return super.hitTest(point, with: event)
    }
    if backgroundView.bounds.contains(backgroundView.convert(point, from: self)) {
      // we check at first interaction view bounds as this view is not inside
      // background view hierachy but its frame is inside background view frame
      // otherwise interaction view will not get touch
      if interactionView.bounds.contains(interactionView.convert(point, from: self)) {
        return interactionView.hitTest(interactionView.convert(point, from: self), with: event)
      } else {
        return backgroundView.hitTest(backgroundView.convert(point, from: self), with: event)
      }
    }
    return nil
  }

  private func setupGesture() {
    dismissKeyboardGesture.addTarget(self, action: #selector(dismissKeyboard))
    addGestureRecognizer(dismissKeyboardGesture)
  }

  @objc private func dismissKeyboard() {
    endEditing(true)
  }

  private func trackOpenReplyMessageEvent() {
    guard let isNewFeed = renderedProps?.isNewFeed else {
      return
    }
    Analytics.shared.track(event: .postsPlayerOpenReply(isNewFeed: isNewFeed))
  }
}

extension PostPlayerView: MessageInputViewDelegate {
  func messageInputViewDidBecomeActive(_ messageInputViewView: MessageInputView) {
    interactionViewIsActiveSubject.onNext(true)
  }

  func messageInputDidBecomeInactive(_ messageInputViewView: MessageInputView) {
    interactionViewIsActiveSubject.onNext(false)
  }

  func messageInputView(_ messageInputView: MessageInputView, didSendText text: String) {
    sendMessageSubject.onNext(text)
    infoView.animate()
  }
}

extension Reactive where Base == PostPlayerView {
  var beginScrolling: Observable<Void> {
    return base.beginScrollingSubject.asObservable()
  }

  var activeMode: Observable<PlayerMode> {
    return base.activeModeSubject.asObservable()
  }

  var tapCloseButton: Observable<Void> {
    return base.headerView.rx.tapCloseButton
  }

  var tapGetDirectionButton: Observable<Void> {
    return base.headerView.rx.tapGetDirectionButton
  }

  var tapClosePlaceFeed: Observable<Void> {
    return base.contentInfoView.rx.tapCloseButton
  }

  var tapPostWithIndex: Observable<Int> {
    return base.postListView.rx.didSelectPostWithIndex
  }

  var isScrolledToEnd: Observable<Void> {
    return base.postListView.rx.isScrolledToEnd
  }

  var sendMessage: Observable<String> {
    return base.sendMessageSubject.asObservable()
  }

  var isInteractionViewActive: Observable<Bool> {
    return base.interactionViewIsActiveSubject.asObservable()
  }
}
