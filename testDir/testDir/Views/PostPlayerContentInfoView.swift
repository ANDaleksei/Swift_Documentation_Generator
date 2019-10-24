//
//  PostPlayerContentInfoView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/8/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift

final class PostPlayerContentInfoView: UIView {

  struct Props: Equatable {
    let feedSourceText: NSAttributedString
    let isCloseButtonVisible: Bool
  }

  private let feedSourceLabel = UILabel()
  fileprivate let closeButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    // configure feed source label
    feedSourceLabel.textColor = .placeMarkText
    feedSourceLabel.font = UIFont.systemFont(ofSize: 15)
    addSubview(feedSourceLabel, constraints: [
      feedSourceLabel.topAnchor.constraint(equalTo: topAnchor),
      feedSourceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      feedSourceLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure close button
    closeButton.setImage(UIImage.closeCircle, for: .normal)
    closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    addSubview(closeButton, constraints: [
      closeButton.leadingAnchor.constraint(greaterThanOrEqualTo: feedSourceLabel.trailingAnchor),
      closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      closeButton.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  func render(props: Props) {
    feedSourceLabel.attributedText = props.feedSourceText
    closeButton.isHidden = !props.isCloseButtonVisible
  }
}

extension Reactive where Base == PostPlayerContentInfoView {
  var tapCloseButton: Observable<Void> {
    return base.closeButton.rx.tap.asObservable()
  }
}
