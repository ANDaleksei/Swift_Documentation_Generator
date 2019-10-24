//
//  PostPlayerHeaderView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/7/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift

final class PostPlayerHeaderView: UIView {

  struct Props: Equatable {
    let iconName: String
    let placeName: String
    let placeAddress: String
    let tagsText: String
  }

  enum Constants {
    static let headerHeight: CGFloat = 84
    static let closeButtonWidth: CGFloat = 28
    static let getDirectionButtonWidth: CGFloat = 134
  }

  private let typeImageView = UIImageView()
  private let nameLabel = UILabel()
  private let addressLabel = UILabel()
  private let tagsLabel = UILabel()
  fileprivate let closeButton = UIButton()
  fileprivate let getDirectionButton = YazaLittleButton(title: "Get direction")
  private var renderedIconName: String?
  private let defaultImage = UIImage(named: "establishment")

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // swiftlint:disable:next function_body_length
  private func setup() {
    // configure type image view
    typeImageView.image = defaultImage
    addSubview(typeImageView, constraints: [
      typeImageView.topAnchor.constraint(equalTo: topAnchor),
      typeImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -6),
      typeImageView.widthAnchor.constraint(equalToConstant: 28),
      typeImageView.heightAnchor.constraint(equalTo: typeImageView.widthAnchor)
    ])

    // configure name label
    nameLabel.font = FontFamily.Rubik.medium.font(size: 17)
    nameLabel.textColor = .buttonsTextAndIcons
    addSubview(nameLabel, constraints: [
      nameLabel.topAnchor.constraint(equalTo: typeImageView.topAnchor, constant: 4),
      nameLabel.leadingAnchor.constraint(equalTo: typeImageView.trailingAnchor, constant: 5)
    ])

    // configure address label
    addressLabel.font = FontFamily.Rubik.regular.font(size: 13)
    addressLabel.textColor = .placeMarkText
    addressLabel.numberOfLines = DeviceType.current.isSameOrSmaller(than: .iPhone6Plus) ? 1 : 2
    addressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    addSubview(addressLabel, constraints: [
      addressLabel.topAnchor.constraint(equalTo: typeImageView.bottomAnchor),
      addressLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
    ])

    // configure tags label
    tagsLabel.font = FontFamily.Rubik.regular.font(size: 13)
    tagsLabel.textColor = .iconsNonactive
    tagsLabel.numberOfLines = 2
    tagsLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    addSubview(tagsLabel, constraints: [
      tagsLabel.topAnchor.constraint(greaterThanOrEqualTo: addressLabel.bottomAnchor, constant: 4),
      tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure close button
    closeButton.setImage(UIImage.closeCircle, for: .normal)
    closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    addSubview(closeButton, constraints: [
      closeButton.topAnchor.constraint(equalTo: topAnchor),
      closeButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8),
      closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 6),
      closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonWidth),
      closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
    ])

    getDirectionButton.backgroundColor = .buttonsBackground
    getDirectionButton.setImage(UIImage.showPlace)
    getDirectionButton.setTitleColor(.buttonsTextAndIcons)
    getDirectionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    addSubview(getDirectionButton, constraints: [
      getDirectionButton.leadingAnchor.constraint(
        greaterThanOrEqualTo: addressLabel.trailingAnchor,
        constant: 8
      ),
      getDirectionButton.leadingAnchor.constraint(
        greaterThanOrEqualTo: tagsLabel.trailingAnchor,
        constant: 8
      ),
      getDirectionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      getDirectionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
      getDirectionButton.heightAnchor.constraint(equalToConstant: 40)
    ])

    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: Constants.headerHeight)
    ])
  }

  func render(props: Props) {
    typeImageView.tintColor = .buttonsTextAndIcons
    if renderedIconName != props.iconName {
      renderedIconName = props.iconName
      let typeImage = UIImage(named: props.iconName) ?? defaultImage
      typeImageView.image = typeImage?.withRenderingMode(.alwaysTemplate)
    }
    nameLabel.text = props.placeName
    setAddress(text: props.placeAddress)
    setTags(text: props.tagsText)
  }

  private func setAddress(text: String) {
    addressLabel.attributedText = NSAttributedString(
      string: text,
      attributes: [
        .foregroundColor: UIColor.placeMarkText,
        .font: FontFamily.Rubik.regular.font(size: 13)!,
        .paragraphStyle: NSParagraphStyle.make(lineHeight: 18)
      ]
    )
  }

  private func setTags(text: String) {
    tagsLabel.attributedText = NSAttributedString(
      string: text,
      attributes: [
        .foregroundColor: UIColor.iconsNonactive,
        .font: FontFamily.Rubik.regular.font(size: 13)!,
        .paragraphStyle: NSParagraphStyle.make(lineHeight: 18)
      ]
    )
  }
}

extension Reactive where Base == PostPlayerHeaderView {
  var tapCloseButton: Observable<Void> {
    return base.closeButton.rx.tap.asObservable()
  }

  var tapGetDirectionButton: Observable<Void> {
    return base.getDirectionButton.rx.tap
  }
}
