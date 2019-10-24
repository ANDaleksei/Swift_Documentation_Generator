//
//  PostPlayerNoPostsView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 5/27/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import RxSwift

final class PostPlayerNoPostsView: UIView {

  private let imageView = UIImageView()
  private let mainLabel = UILabel()
  private let additionalLabel = UILabel()
  fileprivate let actionButton = YazaSmallButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    // configure image view
    imageView.image = UIImage.noPostsIcon
    addSubview(imageView, constraints: [
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 109),
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
    ])

    // configure main label
    mainLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    mainLabel.textColor = .charcoalGrey
    mainLabel.text = "No videos in this\nplace yet"
    mainLabel.numberOfLines = 0
    mainLabel.textAlignment = .center
    addSubview(mainLabel, constraints: [
      mainLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
      mainLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      mainLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5)
    ])

    // configure additional label
    additionalLabel.font = UIFont.systemFont(ofSize: 15)
    additionalLabel.textColor = .wisteria
    additionalLabel.text = "It seems you have not posted\nvideos from this place yet"
    additionalLabel.numberOfLines = 0
    additionalLabel.textAlignment = .center
    addSubview(additionalLabel, constraints: [
      additionalLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 12),
      additionalLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])

    // configure action button
    actionButton.setTitle("Let's make the first one!")
    addSubview(actionButton, constraints: [
      actionButton.topAnchor.constraint(equalTo: additionalLabel.bottomAnchor, constant: 24),
      actionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])
  }

  func toggleButtonVisibility(on: Bool) {
    actionButton.isHidden = !on
  }
}

extension Reactive where Base == PostPlayerNoPostsView {
  var tapButton: Observable<Void> {
    return base.actionButton.rx.controlEvent(.touchUpInside).toVoid()
  }
}
