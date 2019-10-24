//
//  StubbedPostCollectionView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/18/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit

final class StubbedPostCollectionViewCell: UICollectionViewCell, ReusableCell {

  enum StubbedType {
    case gallery
    case player
  }

  private let containerView = UIView()
  private let view = UIView()
  private let upSmallView = UIView()
  private let centerSmallView = UIView()
  private let downSmallView = UIView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    // configure container view
    containerView.layer.cornerRadius = 10
    containerView.layer.addShadow(
      color: UIColor(red: 27.0 / 255.0, green: 16.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0).cgColor,
      opacitiy: 0.1,
      radius: 20,
      offset: CGSize(width: 0, height: 4)
    )
    addSubview(containerView, constraints: [
      containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor)
    ])

    // configure view
    view.layer.cornerRadius = 10
    view.clipsToBounds = true
    containerView.addSubview(view, withEdgeInsets: .zero)

    // configure up small view
    upSmallView.layer.cornerRadius = 5
    addSubview(upSmallView, constraints: [
      upSmallView.topAnchor.constraint(
        equalTo: containerView.bottomAnchor,
        constant: Constants.upSmallViewToContainerConstant
      ),
      upSmallView.centerXAnchor.constraint(equalTo: centerXAnchor),
      upSmallView.heightAnchor.constraint(equalToConstant: 10),
      upSmallView.widthAnchor.constraint(equalTo: widthAnchor)
    ])

    // configure up small view
    centerSmallView.layer.cornerRadius = 5
    addSubview(centerSmallView, constraints: [
      centerSmallView.topAnchor.constraint(equalTo: upSmallView.bottomAnchor, constant: 4),
      centerSmallView.centerXAnchor.constraint(equalTo: centerXAnchor),
      centerSmallView.heightAnchor.constraint(equalToConstant: 10),
      centerSmallView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.775)
    ])

    if Constants.isSmallDevice {
      NSLayoutConstraint.activate([
        centerSmallView.bottomAnchor.constraint(equalTo: bottomAnchor)
      ])
    } else {
      // configure secondary label
      downSmallView.layer.cornerRadius = 4
      addSubview(downSmallView, constraints: [
        downSmallView.topAnchor.constraint(equalTo: centerSmallView.bottomAnchor, constant: 4),
        downSmallView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        downSmallView.centerXAnchor.constraint(equalTo: centerXAnchor),
        downSmallView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.625),
        downSmallView.heightAnchor.constraint(equalToConstant: 8)
      ])
    }
  }

  func render(type: StubbedType) {
    view.backgroundColor = type == .gallery ? .charcoalGrey : .wisteria
    upSmallView.backgroundColor = type == .gallery ? .systemWhite: .charcoalGrey
    centerSmallView.backgroundColor = type == .gallery ? .systemWhite: .charcoalGrey
    downSmallView.backgroundColor = type == .gallery ? .paleGrey40 : .wisteria
  }

  private enum Constants {
    static let isSmallDevice = DeviceType.current.isSameOrSmaller(than: .iPhone5)
    static let upSmallViewToContainerConstant: CGFloat = isSmallDevice ? 7 : 6
  }
}
