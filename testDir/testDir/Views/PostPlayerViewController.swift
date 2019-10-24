//
//  PostPlayerViewController.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 3/7/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import UIKit
import RxSwift
import Dip

// TODO: Rename to Place Details
final class PostPlayerViewController: UIViewController, AlertPresentable, HUDPresentable, RouteToPlacePresentable {

  struct Props: Equatable {
    let viewProps: PostPlayerView.Props
    let playerMode: PlayerMode
    let isLoading: Bool
    let alert: PostPlayerViewModel.Alert?
  }

  private let container: DependencyContainer
  private let viewModel: PostPlayerViewModel
  fileprivate let contentView: PostPlayerView
  private let mainViewController: PostPlayerMainViewController
  private var renderedProps: Props?
  private var isPlayerActive = false
  private var isViewControllerActive = false
  private let errorPresenter = ErrorPresenter()
  private let changePrivateSubject = PublishSubject<Void>()
  private let confirmDeleteSubject = PublishSubject<Void>()
  let disposeBag = DisposeBag()

  init(container: DependencyContainer) {
    self.container = container
    let dependencies = PostPlayerViewModel.Dependencies(
      storage: try! container.resolve(),
      appService: try! container.resolve(),
      profileService: try! container.resolve(),
      locationService: try! container.resolve(),
      postsFeedProvider: try! container.resolve(),
      postsProvider: try! container.resolve(),
      chatsListener: try! container.resolve(),
      messageProviderFabric: { try! container.resolve(arguments: $0) },
      dateService: try! container.resolve(),
      assetProvider: AssetProvider.shared
    )
    self.viewModel = PostPlayerViewModel(dependencies: dependencies)
    self.contentView = PostPlayerView(postsQueue: try! container.resolve())
    self.mainViewController = PostPlayerMainViewController(container: container)
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
    addChildViewController()
    setupChildViewController()
    bindViewModel()
    setupBindings()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    isViewControllerActive = true
    toggleTabBarVisibility()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    isViewControllerActive = false
    toggleTabBarVisibility()
  }

  func getNewestPostView() -> UIView? {
    return contentView.getNewestPostView()
  }

  private func addChildViewController() {
    addChild(mainViewController)
    contentView.addMainView(mainViewController.view)
    mainViewController.didMove(toParent: self)
  }

  private func setupChildViewController() {
    mainViewController.onDidTapReply = { [contentView] in
      contentView.activateMessageField()
    }
  }

  private func bindViewModel() {
    let inputs = PostPlayerViewModel.Inputs(
      viewWillAppear: rx.viewWillAppear.toVoid(),
      viewWillDisappear: rx.viewWillDisappear.toVoid(),
      setPlayerMode: contentView.rx.activeMode,
      tapCloseButton: contentView.rx.tapCloseButton,
      tapClosePlaceFeed: contentView.rx.tapClosePlaceFeed,
      tapPostWithIndex: contentView.rx.tapPostWithIndex,
      isScrolledToEnd: contentView.rx.isScrolledToEnd,
      tapGetDirection: contentView.rx.tapGetDirectionButton,
      sendMessage: contentView.rx.sendMessage,
      tapSharePost: createTapShareObservable(),
      tapFavorite: createTapFavoriteObservable(),
      tapMoreInfo: mainViewController.rx.tapsMoreInfo,
      changePrivateness: changePrivateSubject.asObservable(),
      deletePost: confirmDeleteSubject.asObservable(),
      dismissError: errorPresenter.dismissed
    )

    let outputs = viewModel.makeOutputs(from: inputs)

    outputs.props
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] props in
        self.render(props: props)
      })
      .disposed(by: disposeBag)

    outputs.result
      .subscribe(onNext: { [unowned self] in self.callDelegate(result: $0) })
      .disposed(by: disposeBag)

    outputs.changes
      .subscribe()
      .disposed(by: disposeBag)

    outputs.route
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in self.navigate(by: $0) })
      .disposed(by: disposeBag)

    Observable.merge(
        contentView.rx.beginScrolling,
        contentView.rx.isInteractionViewActive.filter { $0 }.toVoid(),
        outputs.interruptPlaybackTrigger
      )
      .subscribe(onNext: { [mainViewController] _ in
        mainViewController.pauseVideo()
      })
      .disposed(by: disposeBag)
  }

  private func setupBindings() {
    contentView.endScrollingSubject
      .subscribe(onNext: { [mainViewController] () in
        mainViewController.playVideoIfNeeded()
      })
      .disposed(by: disposeBag)
  }

  private func createTapFavoriteObservable() -> Observable<Void> {
    return Observable.create { [mainViewController, contentView] observer in
      mainViewController.onDidTapFavorite = {
        observer.onNext(())
      }
      contentView.interactionView.onDidTapFavorite = {
        observer.onNext(())
      }
      return Disposables.create()
    }
  }

  private func createTapShareObservable() -> Observable<Void> {
    return Observable.create { [mainViewController, contentView] observer in
      mainViewController.onDidTapShare = {
        observer.onNext(())
      }
      contentView.interactionView.onDidTapShare = {
        observer.onNext(())
      }
      return Disposables.create()
    }
  }

  private func toggleTabBarVisibility() {
    guard let tabBarController = tabBarController as? YazaTabBarController else {
      return
    }
    tabBarController.setTabBarHidden(isViewControllerActive && isPlayerActive)
  }

  private func navigate(by route: PostPlayerViewModel.Route) {
    switch route {
    case .showShareList(let sharePostInfo):
      mainViewController.pauseVideo()
      showShareList(sharePostInfo: sharePostInfo)
    }
  }

  private func render(props: Props) {
    contentView.render(props: props.viewProps)
    toggleLoading(on: props.isLoading)
    isPlayerActive = props.playerMode.isPlayerActive
    if isViewControllerActive {
      toggleTabBarVisibility()
    }

    if let alert = props.alert, alert != renderedProps?.alert {
      showAlert(alert)
    }

    renderedProps = props
  }

  private func showShareList(sharePostInfo: SharePostInfo) {
    let viewController = ShareNavigationController(sharePostInfo: sharePostInfo, container: container)
    if presentedViewController != nil, presentedViewController is UIAlertController {
      dismiss(animated: true)
    }
    viewController.modalPresentationStyle = .overCurrentContext
    present(viewController, animated: true)
  }

  private func callDelegate(result: PostPlayerViewModel.Result) {
    switch result {
    case .getDirection(let location):
      showDirection(to: location)
    }
  }
}

// MARK: - Alerts
extension PostPlayerViewController {
  private func showAlert(_ alert: PostPlayerViewModel.Alert) {
    switch alert {
    case .moreInfo(let isPrivatePost):
      showMoreInfoAlert(isPrivatePost: isPrivatePost)

    case .error(let error):
      errorPresenter.present(error: error, on: self)

    case .favorite:
      errorPresenter.present(
        title: "This video was bookmarked",
        message: "Very soon you will be able to watch your bookmarked videos on the map.",
        actions: [.init(name: "Got it")],
        on: self
      )
    }
  }

  private func showMoreInfoAlert(isPrivatePost: Bool) {
    let changePrivatenessAction = ErrorPresenter.Action(
      name: isPrivatePost ? "Make public" : "Make private",
      style: .default,
      handler: { [weak self] in self?.showChangePrivatenessAlert(toPrivate: !isPrivatePost) }
    )
    let deleteAction = ErrorPresenter.Action(
      name: "Delete video",
      style: .destructive,
      handler: { [weak self] in self?.showDeletePostAlert() }
    )
    let cancelAction = ErrorPresenter.Action(name: "Cancel", style: .cancel)

    errorPresenter.present(
      title: nil,
      message: nil,
      actions: [changePrivatenessAction, deleteAction, cancelAction],
      style: .actionSheet,
      on: self
    )
  }

  private func showChangePrivatenessAlert(toPrivate: Bool) {
    let toPrivateMessage = "Private video is visible only for you."
    let toPublicMessage = "Public video is visible for all your network."
    errorPresenter.present(
      title: "Make this video \(toPrivate ? "private" : "public")?",
      message: toPrivate ? toPrivateMessage : toPublicMessage,
      actions: [
        ErrorPresenter.Action(
          name: "Make \(toPrivate ? "private" : "public")",
          style: .destructive,
          handler: { [changePrivateSubject] in changePrivateSubject.onNext(()) }
        ),
        ErrorPresenter.Action(name: "Cancel", style: .default)
      ],
      on: self
    )
  }

  private func showDeletePostAlert() {
    errorPresenter.present(
      title: "Delete video?",
      message: "Would you like to delete this video?",
      actions: [
        ErrorPresenter.Action(
          name: "Delete",
          style: .destructive,
          handler: { [confirmDeleteSubject] in confirmDeleteSubject.onNext(()) }
        ),
        ErrorPresenter.Action(name: "Cancel", style: .default)
      ],
      on: self
    )
  }
}

extension Reactive where Base == PostPlayerViewController {
  var isScrolling: Observable<Bool> {
    return Observable.merge(
      base.contentView.beginScrollingSubject.map(to: true),
      base.contentView.endScrollingSubject.map(to: false)
    )
  }
}
