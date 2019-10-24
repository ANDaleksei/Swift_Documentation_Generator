//
//  VideoPlayerViewController.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/21/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift

final class VideoPlayerViewController: UIViewController {

  enum Source: Equatable {
    case local
    case feed(Place.Identifier?)
  }

  struct Props: Equatable {
    let postVideoInfo: [PostVideoInfo]
    let source: Source
    let selectedPostIndex: Int?

    static var empty: Props {
      return .init(postVideoInfo: [], source: .local, selectedPostIndex: nil)
    }
  }

  private let viewModel: VideoPlayerViewModel
  fileprivate let contentView = VideoPlayerView()
  // we use behavior subject here because first value is emitted before it is subscribed
  // using publish subject it will be skipped
  private let postVideoInfoSubject = BehaviorSubject<[PostVideoInfo]>(value: [])
  private let sourceSubject = BehaviorSubject<Source?>(value: nil)
  private let selectedPostSubject = BehaviorSubject<Int?>(value: nil)
  private let pauseSubject = PublishSubject<Void>()
  fileprivate let didFinishPlayingSubject = PublishSubject<Void>()
  // if we need start playing without waiting user action we use subject
  // otherwise action button will trigger player state
  private let startPlayingSubject = PublishSubject<Void>()
  // this subject let outside classes to know whether player is playing video
  fileprivate let isPlayingSubject = PublishSubject<Bool>()
  fileprivate let activePostIndexSubject = PublishSubject<Int>()
  private let disposeBag = DisposeBag()
  var reuseBag = DisposeBag()

  init() {
    self.viewModel = VideoPlayerViewModel(assetProvider: AssetProvider.shared)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
  }

  private func bindViewModel() {

    let inputs = VideoPlayerViewModel.Inputs(
      viewWillDisappear: rx.viewWillDisappear.asObservable().toVoid(),
      postVideoInfo: postVideoInfoSubject.asObservable().distinctUntilChanged(),
      postsSource: sourceSubject.ignoreNil(),
      selectedPost: selectedPostSubject.ignoreNil(),
      rate: contentView.rx.rate,
      startPlaying: startPlayingSubject.asObservable(),
      pause: pauseSubject.asObservable(),
      tapLeft: contentView.rx.tapLeft
        .throttle(.milliseconds(300), latest: true, scheduler: MainScheduler.instance),
      tapRight: contentView.rx.tapRight
        .throttle(.milliseconds(300), latest: true, scheduler: MainScheduler.instance),
      tapCenter: contentView.rx.tapCenter,
      tapBottom: contentView.rx.tapBottom,
      tapActionButton: contentView.rx.tapActionButton,
      didFinishPlaying: contentView.rx.didFinishPlaying
    )

    let outputs = viewModel.makeOutputs(from: inputs)

    let props = outputs.props
      .share(replay: 1, scope: .whileConnected)

    props.observeOn(MainScheduler.instance)
      .distinctUntilChanged()
      .subscribe(onNext: { [unowned self] props in self.contentView.render(props: props) })
      .disposed(by: disposeBag)

    props.map { $0.isPlaying }
      .bind(to: isPlayingSubject.asObserver())
      .disposed(by: disposeBag)

    outputs.activePostIndex
      .bind(to: activePostIndexSubject)
      .disposed(by: disposeBag)

    outputs.result
      .toVoid()
      .bind(to: didFinishPlayingSubject)
      .disposed(by: disposeBag)

    outputs.stateChanges.subscribe().disposed(by: disposeBag)
  }

  func render(props: Props) {
    postVideoInfoSubject.onNext(props.postVideoInfo)
    sourceSubject.onNext(props.source)
    selectedPostSubject.onNext(props.selectedPostIndex)
  }

  func startPlayingVideo() {
    startPlayingSubject.onNext(())
  }

  func pauseVideo() {
    pauseSubject.onNext(())
  }
}

extension Reactive where Base == VideoPlayerViewController {
  var didFinishPlaying: Observable<Void> {
    return base.didFinishPlayingSubject.asObservable()
  }

  var isPlaying: Observable<Bool> {
    return base.isPlayingSubject.asObservable().distinctUntilChanged()
  }

  var activePostIndex: Observable<Int> {
    return base.activePostIndexSubject.asObservable()
  }
}
