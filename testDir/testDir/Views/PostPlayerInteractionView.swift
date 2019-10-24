//
//  PostPlayerInteractionView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/9/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

final class PostPlayerInteractionView: UIView {

  enum Mode {
    case solid
    case transparent

    var isSolid: Bool {
      switch self {
      case .solid:
        return true
      case .transparent:
        return false
      }
    }
  }

  struct Props: Equatable {
    let isViewActive: Bool
    let isFavorite: Bool
    let messagePlaceholder: String
    let isSendingMessageAvailable: Bool
  }

  enum Constants {
    static var height: CGFloat = 40
  }

  private lazy var stackView = UIStackView(arrangedSubviews: [favoriteButton, shareButton, replyButton])
  fileprivate let favoriteButton = InteractionButton(image: UIImage.favorites)
  fileprivate let replyButton = UIButton()
  fileprivate let shareButton = InteractionButton(image: UIImage.shareDark)
  private let mode: Mode
  private var isViewActive = false
  private var isVisible = true
  // callback
  var onDidTapFavorite: (() -> Void)?
  var onDidTapShare: (() -> Void)?
  var onDidTapReply: (() -> Void)?

  init(mode: Mode) {
    self.mode = mode
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {

    // configure favorite button
    if !mode.isSolid {
      favoriteButton.backgroundColor = .clear
    }
    favoriteButton.addTarget(self, action: #selector(handleFavoriteTap), for: .touchUpInside)

    // configure share button
    if !mode.isSolid {
      shareButton.backgroundColor = .clear
    }
    shareButton.addTarget(self, action: #selector(handleShareTap), for: .touchUpInside)

    // configure reply button
    replyButton.titleEdgeInsets.left = 16
    replyButton.contentHorizontalAlignment = .leading
    replyButton.backgroundColor = mode.isSolid ? .buttonsBackground : .clear
    replyButton.layer.cornerRadius = 12
    replyButton.layer.borderWidth = mode.isSolid ? 0 : 1
    replyButton.layer.borderColor = mode.isSolid ? UIColor.clear.cgColor : UIColor.buttonsTextAndIcons.cgColor
    let color: UIColor = mode.isSolid ? .iconsNonactive : .buttonsTextAndIcons
    replyButton.setTitleColor(color, for: .normal)
    replyButton.setTitleColor(color.withAlphaComponent(0.7), for: .highlighted)
    replyButton.titleLabel?.lineBreakMode = .byTruncatingTail
    replyButton.addTarget(self, action: #selector(handleReplyTap), for: .touchUpInside)

    addSubview(stackView, constraints: [
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    stackView.spacing = 16

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: Constants.height)
    ])
  }

  func render(props: Props) {
    if isViewActive != props.isViewActive {
      isHidden = !(props.isViewActive && isVisible)
    }
    isViewActive = props.isViewActive
    favoriteButton.setImage(props.isFavorite ? UIImage.favoriteFull : UIImage.favorites)
    replyButton.setTitle(props.messagePlaceholder, for: .normal)
    toggleTextFieldVisibility(on: props.isSendingMessageAvailable)
  }

  func toggleIsVisible(on: Bool) {
    isVisible = on
    isHidden = !(isViewActive && isVisible)
  }

  private func toggleTextFieldVisibility(on: Bool) {
    replyButton.alpha = on ? 1.0 : 0.0
    replyButton.isUserInteractionEnabled = on
  }

  @objc private func handleFavoriteTap() {
    onDidTapFavorite?()
  }

  @objc private func handleReplyTap() {
    onDidTapReply?()
  }

  @objc private func handleShareTap() {
    onDidTapShare?()
  }
}
