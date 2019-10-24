//
//  PostPlayerInfoView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 9/18/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit

final class PostPlayerInfoView: UIView {

  struct Props: Equatable {
    let text: String
  }

  private let textLabel = UILabel()
  private let overlayView = VisualEffectView(
    blurPrefereneces: BlurPreferences(radius: 10, colorTint: .systemWhite, colorTintAlpha: 0.7)
  )

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    backgroundColor = UIColor.systemWhite.withAlphaComponent(0.7)
    layer.addShadow(opacitiy: 0.05, radius: 10, offset: CGSize(width: 0, height: 1))
    roundCornersContinuosly(radius: 12)
    clipsToBounds = true

    addSubview(overlayView, withEdgeInsets: .zero)

    // configure text label
    textLabel.font = FontFamily.Rubik.medium.font(size: 13)
    textLabel.textColor = .containerLogin
    textLabel.textAlignment = .center
    addSubview(textLabel, withEdgeInsets: .init(top: 17, left: 10, bottom: 15, right: 10))
  }

  func render(props: Props) {
    textLabel.text = props.text
  }

  func animate() {
    UIView.animateKeyframes(withDuration: 2, delay: 0, options: [], animations: { [weak self] in
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) { [weak self] in
        self?.alpha = 1.0
      }
      UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) { [weak self] in
        self?.alpha = 0.0
      }
    })
  }
}
