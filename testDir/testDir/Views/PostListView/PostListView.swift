//
//  PostListView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift

final class PostListView: UIView {

  enum Constants {
    static let isSmallDevice = DeviceType.current.isSameOrSmaller(than: .iPhone5)
    static let isLessThanX = DeviceType.current.isSameOrSmaller(than: .iPhone6Plus)
    static let collectionViewInset: CGFloat = 16
    static let itemPadding: CGFloat = 10
    static let itemWidth: CGFloat = isSmallDevice ? 64 : 80
    static var itemHeight: CGFloat {
      if isSmallDevice {
        return 114
      } else if isLessThanX {
        return 131
      } else {
        return 140
      }
    }
  }

  enum CellType: Equatable {
    case post(PostPreviewCollectionViewCell.Props)
    case stubbed
  }

  struct Props: Equatable {
    let posts: [CellType]
    let isCollectionViewInteractive: Bool
    let activePostIndex: Int?
    let selectedPlace: MarkerIdentifier?
  }

  private let postsQueue: PostsQueue
  private let layout = UICollectionViewFlowLayout()
  fileprivate lazy var collectionView = UICollectionView(
    frame: CGRect(x: 0, y: 0, width: 0, height: 0),
    collectionViewLayout: layout
  )
  private var renderedProps: Props?
  fileprivate let isScrolledToEndSubject = PublishSubject<Void>()

  init(postsQueue: PostsQueue) {
    self.postsQueue = postsQueue
    super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.itemHeight))
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = .clear

    layout.scrollDirection = .horizontal
    let inset = Constants.collectionViewInset
    layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    layout.itemSize = CGSize(
      width: Constants.itemWidth,
      height: Constants.itemHeight
    )

    collectionView.register(cell: PostPreviewCollectionViewCell.self)
    collectionView.register(cell: StubbedPostCollectionViewCell.self)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.clipsToBounds = false
    collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
    addSubview(collectionView, withEdgeInsets: .zero)
    NSLayoutConstraint.activate([
      collectionView.heightAnchor.constraint(equalToConstant: Constants.itemHeight)
    ])
  }

  func render(props: Props) {
    collectionView.isUserInteractionEnabled = props.isCollectionViewInteractive
    let renderedProps = self.renderedProps
    self.renderedProps = props
    if props.posts != renderedProps?.posts {
      collectionView.reloadData()
      layout.sectionInset.left = calculateInset(for: props)
    }
    if props.activePostIndex != renderedProps?.activePostIndex {
      scrollToItem(index: props.activePostIndex)
    }
    if props.selectedPlace != renderedProps?.selectedPlace {
      collectionView.setContentOffset(.zero, animated: false)
    }
  }

  func getNewestPostView() -> UIView? {
    let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
    return cell?.contentView
  }

  func getLastPostView() -> UIView? {
    guard let posts = renderedProps?.posts else {
      return nil
    }

    let cell = collectionView.cellForItem(at: IndexPath(item: posts.count - 1, section: 0))
    return cell?.contentView
  }

  private func scrollToItem(index: Int?) {
    guard let index = index else {
      return
    }

    let indexPath = IndexPath(item: index, section: 0)
    guard collectionView.numberOfItems(inSection: 0) > indexPath.item else {
      log.error("Collection View data source is out of sync!")
      return
    }
    guard !collectionView.isDragging && !collectionView.isDecelerating else {
      return
    }
    let inset = Constants.collectionViewInset
    let rect = CGRect(
      x: CGFloat(indexPath.row) * (Constants.itemWidth + Constants.itemPadding) + inset,
      y: 0,
      width: Constants.itemWidth,
      height: Constants.itemHeight
    )
    // We need to extend width in order not to align cell to screen size
    let extendedRect = rect.insetBy(dx: -10, dy: 0)
    collectionView.scrollRectToVisible(extendedRect, animated: true)
  }

  private func calculateInset(for props: Props) -> CGFloat {
    let postsCount = props.posts.count
    let width = frame.width
    let postsWidth = CGFloat(postsCount) * Constants.itemWidth
    let padding = Constants.collectionViewInset + CGFloat(postsCount - 1) * Constants.itemPadding
    return max(width - postsWidth - padding, Constants.collectionViewInset)
  }

  private func isRectVisibleInCollectionView(_ rect: CGRect) -> Bool {
    let offset = collectionView.contentOffset
    let bounds = collectionView.bounds
    return offset.x < rect.minX && rect.maxX < offset.x + bounds.width
  }
}

extension PostListView: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return renderedProps?.posts.count ?? 0
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {

    switch renderedProps?.posts[indexPath.row] {
    case .some(.post(let props)):
      let cell: PostPreviewCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.render(props: props)
      cell.setQueue(postsQueue)
      return cell

    case .some(.stubbed):
      let cell: StubbedPostCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.render(type: .player)
      return cell

    case .none:
      return UICollectionViewCell()
    }
  }
}

extension PostListView: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentWidth = collectionView.contentSize.width
    let frameWidth = collectionView.frame.width
    guard contentWidth > frameWidth, scrollView.isUserInteractionEnabled else {
      return
    }
    let xOffset = collectionView.contentOffset.x
    if xOffset + frameWidth + 200 > contentWidth {
      isScrolledToEndSubject.onNext(())
    }
  }
}

extension Reactive where Base == PostListView {
  var didSelectPostWithIndex: Observable<Int> {
    return base.collectionView.rx.itemSelected.asObservable().map(\.item)
  }

  var isScrolledToEnd: Observable<Void> {
    return base.isScrolledToEndSubject.asObservable()
  }
}
