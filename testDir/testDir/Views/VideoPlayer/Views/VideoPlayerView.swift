//
//  VideoPlayerView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/12/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation

final class VideoPlayerView: UIView {

  struct Props: Equatable {
    let videoViewProps: VideoView.Props
    let isPlaying: Bool
    let isActionButtonVisible: Bool
    let timeText: String
    let progress: Double
  }

  fileprivate let videoView = VideoView(isQualityTrackerEnabled: true)
  fileprivate let actionButton = UIButton()
  private let timeLabel = UILabel()
  private let progressLine = UIView()
  private var progressTrailingConstraint: NSLayoutConstraint!

  fileprivate let leftTapSubject = PublishSubject<Void>()
  fileprivate let centerTapSubject = PublishSubject<Void>()
  fileprivate let bottomTapSubject = PublishSubject<Void>()
  fileprivate let rightTapSubject = PublishSubject<Void>()
  // callback
  var onDidChangeAreControlsVisible: ((Bool) -> Void)?

  private var renderedProps: Props?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    clipsToBounds = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    tapGesture.numberOfTapsRequired = 1
    addGestureRecognizer(tapGesture)

    // configure vidoe view
    addSubview(videoView, withEdgeInsets: .zero)

    // configure button
    actionButton.setImage(UIImage.playIconSolid, for: .normal)
    addSubview(actionButton, constraints: [
      actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
      actionButton.widthAnchor.constraint(equalToConstant: 64),
      actionButton.heightAnchor.constraint(equalTo: actionButton.widthAnchor)
    ])

    // configure time label
    timeLabel.font = UIFont.systemFont(ofSize: 17)
    timeLabel.textColor = .white
    timeLabel.isHidden = true
    addSubview(timeLabel, constraints: [
      timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
    ])

    // configure progress line
    progressLine.backgroundColor = .elementsUnread
    progressLine.isHidden = true
    progressTrailingConstraint = progressLine.trailingAnchor.constraint(equalTo: trailingAnchor)
    addSubview(progressLine, constraints: [
      progressLine.leadingAnchor.constraint(equalTo: leadingAnchor),
      progressTrailingConstraint,
      progressLine.bottomAnchor.constraint(equalTo: bottomAnchor),
      progressLine.heightAnchor.constraint(equalToConstant: 4)
    ])
  }

  func render(props: Props) {
    renderVideoView(props: props)
    updateActionButtonUI(isPlaying: props.isPlaying, isVisible: props.isActionButtonVisible)
    updateTimeLabel(props: props)
    updateProgressLine(isPlaying: props.isPlaying, progress: props.progress)
    checkAreControlsVisibleChanges(isVisible: props.isActionButtonVisible)
    renderedProps = props
  }

  private func renderVideoView(props: Props) {
    if renderedProps?.videoViewProps != props.videoViewProps {
      videoView.render(props: props.videoViewProps)
    }
  }

  private func updateActionButtonUI(isPlaying: Bool, isVisible: Bool) {
    actionButton.alpha = isVisible ? 1.0 : 0.0
    let image = isPlaying ? UIImage.pauseIconSolid  : UIImage.playIconSolid
    actionButton.setImage(image, for: .normal)
  }

  private func updateTimeLabel(props: Props) {
    timeLabel.isHidden = !props.isPlaying || props.isActionButtonVisible
    timeLabel.text = props.timeText
  }

  private func updateProgressLine(isPlaying: Bool, progress: Double) {
    progressLine.isHidden = !isPlaying
    progressTrailingConstraint.constant = -bounds.width * CGFloat(1.0 - progress)
  }

  private func checkAreControlsVisibleChanges(isVisible: Bool) {
    if renderedProps?.isActionButtonVisible != isVisible {
      onDidChangeAreControlsVisible?(isVisible)
    }
  }

  @objc private func handleTap(recognizer: UITapGestureRecognizer) {
    let touchPoint = recognizer.location(in: self)
    guard touchPoint.y < self.bounds.height * 0.8 else {
      bottomTapSubject.onNext(())
      return
    }
    let leftToCenterBorder = self.bounds.width / 3
    let centerToRightBorder = 2 * self.bounds.width / 3
    if touchPoint.x < leftToCenterBorder {
      leftTapSubject.onNext(())
    } else if touchPoint.x < centerToRightBorder {
      centerTapSubject.onNext(())
    } else {
      rightTapSubject.onNext(())
    }
  }
}

extension Reactive where Base == VideoPlayerView {

  var rate: Observable<Double> {
    return base.videoView.rx.rate
  }

  var tapLeft: Observable<Void> {
    return base.leftTapSubject.asObservable()
  }

  var tapRight: Observable<Void> {
    return base.rightTapSubject.asObservable()
  }

  var tapCenter: Observable<Void> {
    return base.centerTapSubject.asObservable()
  }

  var tapBottom: Observable<Void> {
    return base.bottomTapSubject.asObservable()
  }

  var tapActionButton: Observable<Void> {
    return base.actionButton.rx.tap.asObservable()
  }

  var didFinishPlaying: Observable<Void> {
    return base.videoView.rx.didEndPlay
  }
}
