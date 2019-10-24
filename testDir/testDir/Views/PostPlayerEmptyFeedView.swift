//
//  PostPlayerEmptyFeedView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/26/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

final class PostPlayerEmptyFeedView: UIView {

  enum Props {
    case hidden
    case feedIsEmpty
  }

  private let imageView = UIImageView()
  private let mainLabel = UILabel()
  private let additionalLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    // configure image view
    addSubview(imageView, constraints: [
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])

    // configure main label
    mainLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    mainLabel.textColor = .buttonsTextAndIcons
    mainLabel.numberOfLines = 0
    mainLabel.textAlignment = .center
    addSubview(mainLabel, constraints: [
      mainLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
      mainLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 48),
      mainLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -48),
      mainLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])

    // configure additional label
    additionalLabel.numberOfLines = 0
    additionalLabel.textAlignment = .center
    addSubview(additionalLabel, constraints: [
      additionalLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 16),
      additionalLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 48),
      additionalLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -48),
      additionalLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      additionalLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])
  }

  func render(props: Props) {
    renderImage(props: props)
    renderMainLabel(props: props)
    renderAdditionalLabel(props: props)
  }

  private func renderImage(props: Props) {
    switch props {
    case .hidden:
      imageView.isHidden = true
    case .feedIsEmpty:
      imageView.isHidden = false
      imageView.image = UIImage.emptyNewFeed
    }
  }

  private func renderMainLabel(props: Props) {
    switch props {
    case .hidden:
      mainLabel.isHidden = true
    case .feedIsEmpty:
      mainLabel.isHidden = false
      mainLabel.text = "Nothing to see here, yet!"
    }
  }

  private func renderAdditionalLabel(props: Props) {
    switch props {
    case .hidden:
      additionalLabel.isHidden = true
    case .feedIsEmpty:
      additionalLabel.isHidden = false
      let text = """
      Add more friends to see more posts.
      Make sure their phone numbers are
      in your contacts, then add them
      in the My Network section of your profile.
      """
      setAdditionalLabelText(text)
    }
  }

  private func setAdditionalLabelText(_ text: String) {
    additionalLabel.attributedText = NSAttributedString(
      string: text,
      attributes: [
        .foregroundColor: UIColor.placeMarkText,
        .font: UIFont.systemFont(ofSize: 15),
        .paragraphStyle: NSParagraphStyle.make(lineHeight: 20, alignment: .center)
      ]
    )
  }
}
