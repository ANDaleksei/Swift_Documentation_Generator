//
//  PostPreviewCollectionViewCell.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift

final class PostPreviewCollectionViewCell: UICollectionViewCell, ReusableCell {

  struct Props: Equatable {
    let avatar: ImageSource
    let isPost: Bool
    let authorName: String
    let placeName: String
    let isPlaceNameHidden: Bool
    let secondaryText: String
    let isRead: Bool
    let isActive: Bool
    let isPrivate: Bool
    let isEnable: Bool
    let uploadingPostID: ComposedPost.Identifier?
  }

  private let backgroundGradientView = GradientView(parameters: .init(
    colors: [.buttonsBackground, UIColor.rose2.withAlphaComponent(0.0)],
    locations: [0, 1],
    startPoint: CGPoint(x: -0.25, y: 0.5),
    endPoint: CGPoint(x: 1.25, y: 0.5)
  ))
  private let imageContainerView = UIView()
  private let imageView = UIImageView()
  private let authorNameLabel = UILabel()
  private let placeNameLabel = UILabel()
  private let secondaryLabel = UILabel()
  private let isPrivateImageView = UIImageView()
  private let uploadProgressView = QueueUploadProgressView()
  private let uploadingIDSubject = BehaviorSubject<ComposedPost.Identifier?>(value: nil)
  private var queueWasSet = false
  private let disposeBag = DisposeBag()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.kf.cancelDownloadTask()
    imageView.image = nil
  }

  // swiftlint:disable:next function_body_length
  private func setup() {
    contentView.transform = CGAffineTransform(scaleX: -1, y: 1)

    backgroundGradientView.roundCornersContinuosly(radius: 17)
    backgroundGradientView.clipsToBounds = true
    contentView.addSubview(backgroundGradientView, withEdgeInsets: .zero)

    // configure image container view
    imageContainerView.roundCornersContinuosly(radius: 14)
    imageContainerView.layer.borderColor = UIColor.elementsUnread.cgColor
    contentView.addSubview(imageContainerView, constraints: [
      imageContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
      imageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
      imageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
      imageContainerView.widthAnchor.constraint(equalTo: imageContainerView.heightAnchor)
    ])

    // configure image view
    imageView.roundCornersContinuosly(radius: 14)
    imageView.clipsToBounds = true
    imageView.backgroundColor = .white
    let inset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    imageContainerView.addSubview(imageView, withEdgeInsets: inset)

    // configure main label
    authorNameLabel.textAlignment = .center
    authorNameLabel.textColor = .textMain
    authorNameLabel.font = FontFamily.Rubik.regular.font(size: 12)
    authorNameLabel.setContentHuggingPriority(.required, for: .vertical)

    // configure place name label
    placeNameLabel.textAlignment = .center
    placeNameLabel.textColor = .buttonsTextAndIcons
    placeNameLabel.font = FontFamily.Rubik.medium.font(size: 11)

    // configure secondary label
    secondaryLabel.font = FontFamily.Rubik.regular.font(size: 11)
    secondaryLabel.textColor = .textSecond
    secondaryLabel.textAlignment = .justified
    secondaryLabel.numberOfLines = 0

    // empty view, we need to add it to stackview in order to stretch empty space
    // when some label is hidden
    let stretchView = UIView()

    // configure stack view
    let stackView = UIStackView(arrangedSubviews: [authorNameLabel, placeNameLabel, secondaryLabel, stretchView])
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.setCustomSpacing(-1, after: authorNameLabel)
    stackView.setCustomSpacing(0, after: placeNameLabel)
    contentView.addSubview(stackView, constraints: [
      stackView.topAnchor.constraint(
        equalTo: imageContainerView.bottomAnchor,
        constant: Constants.labelsTopPadding
      ),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    // configure is private image view
    isPrivateImageView.image = UIImage.isPrivateIcon
    isPrivateImageView.isHidden = true
    contentView.addSubview(isPrivateImageView, constraints: [
      isPrivateImageView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
      isPrivateImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8),
      isPrivateImageView.widthAnchor.constraint(equalToConstant: 28),
      isPrivateImageView.heightAnchor.constraint(equalTo: isPrivateImageView.widthAnchor)
    ])

    contentView.addSubview(uploadProgressView, constraints: [
      uploadProgressView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
      uploadProgressView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
      uploadProgressView.widthAnchor.constraint(equalToConstant: 35),
      uploadProgressView.heightAnchor.constraint(equalToConstant: 35)
    ])
  }

  func render(props: Props) {
    configureImageView(props: props)
    configureLabels(props: props)
    secondaryLabel.text = props.secondaryText
    isPrivateImageView.isHidden = !props.isPrivate
    backgroundGradientView.alpha = props.isActive ? 0.4 : 0.0
    isUserInteractionEnabled = props.isEnable
    alpha = props.isEnable ? 1.0 : 0.4
    uploadingIDSubject.onNext(props.uploadingPostID)
  }

  func setQueue(_ queue: PostsQueue) {
    guard !queueWasSet else {
      return
    }
    queueWasSet = true
    setupBinding(queue: queue)
  }

  private func setupBinding(queue: PostsQueue) {
    uploadingIDSubject.asObservable()
      .distinctUntilChanged()
      .flatMapLatest { [uploadProgressView] id -> Observable<Double?> in
        guard let id = id else {
          uploadProgressView.render(props: .none)
          return .never()
        }
        return queue.observeProgress(for: id)
      }
      .map { progress -> QueueUploadProgressView.Props in
        guard let progress = progress else {
          return .none
        }
        return progress > 0 ? .progress(progress) : .inQueue
      }
      .subscribe(onNext: { [uploadProgressView] in uploadProgressView.render(props: $0) })
      .disposed(by: disposeBag)
  }

  private func configureImageView(props: Props) {
    imageView.setImage(
      props.avatar,
      placeholder: UIImage.videoPlaceholder,
      preferredSize: CGSize(width: bounds.width, height: bounds.width)
    )
    imageContainerView.layer.borderWidth = props.isRead ? 0 : 2.5
  }

  private func configureLabels(props: Props) {
    authorNameLabel.text = props.authorName
    placeNameLabel.isHidden = props.isPlaceNameHidden
    placeNameLabel.text = props.placeName
  }

  private enum Constants {
    static let isSmallDevice = DeviceType.current.isSameOrSmaller(than: .iPhone5)
    static let labelsTopPadding: CGFloat = isSmallDevice ? 4 : 9
    static let fontSize: CGFloat = isSmallDevice ? 11 : 13
  }
}
