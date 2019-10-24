//
//  PostPlayerBottomView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/12/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift

final class PostPlayerBottomView: UIView {

  private let containerView = UIStackView()
  fileprivate let shareButton = UIButton()

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    // configure container view
    containerView.spacing = 16
    containerView.distribution = .equalSpacing
    addSubview(containerView, constraints: [
      containerView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure share button
    containerView.addArrangedSubview(shareButton)
    shareButton.setImage(UIImage.shareDark, for: .normal)
    shareButton.backgroundColor = .buttonsBackground
    shareButton.roundCornersContinuosly(radius: 12)
    shareButton.addConstraints([
      shareButton.widthAnchor.constraint(equalToConstant: 40),
      shareButton.heightAnchor.constraint(equalToConstant: 40)
    ])

    // TODO: Add button "Add to favourites"
  }

  func toggleShareButtonEnabled(on: Bool) {
    shareButton.isHidden = !on
  }

  private enum Constants {
    static let isSmallDevice = DeviceType.current.isSameOrSmaller(than: .iPhone5)
    static let topConstant: CGFloat = isSmallDevice ? 7 : 16
  }
}

extension Reactive where Base == PostPlayerBottomView {
  var tapShareButton: Observable<Void> {
    return base.shareButton.rx.tap.asObservable()
  }
}
