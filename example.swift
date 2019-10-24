//
//  CaptureSessionManager.swift
//  YazaKit
//
//  Created by Arthur Myronenko on 1/11/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation
import RxSwift
import AVFoundation
import NextLevel

protocol CaptureSessionManager {
  var zoomFactor: Float { get }
  var isLightningActive: Observable<Bool> { get }
  var isSessionActive: Observable<Bool> { get }
  var previewLayer: CALayer { get }
  var devicePosition: DevicePosition { get }

  func configure() -> Single<Void>

  func startRunning() -> Single<Void>
  func stopRunning() -> Single<Void>

  func startRecording() -> Single<Void>

  /// The methods stops recording and copies recorded clip into the Documents folder.
  ///
  /// - Returns: The name of the clip and duration in seconds
  func stopRecording() -> Single<(String, CMTime)>
  func switchCamera() -> Single<Void>
  func toggleLightning()
  func set(zoomFactor: Float)
}

final class CaptureSessionManagerImpl: CaptureSessionManager {

  private enum Constants {
    static var retryDelay: Int {
      if #available(iOS 12, *) {
        return 100
      } else {
        return 300
      }
    }
  }

  private let videoKit = NextLevel.shared
  private let sessionListener = CaptureSessionListener()
  private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .userInitiated)

  init() {
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetoothA2DP, .mixWithOthers])
    } catch {
      log.error("Couldn't set an AVAudioSession category", details: [
        "error": "\(error)"
        ])
    }

    videoKit.delegate = sessionListener
    videoKit.videoDelegate = sessionListener
    videoKit.flashDelegate = sessionListener
    videoKit.deviceDelegate = sessionListener
    videoKit.focusMode = .autoFocus
    videoKit.automaticallyConfiguresApplicationAudioSession = false
  }

  var isSessionActive: Observable<Bool> {
    return Observable.merge(
      sessionListener.sessionDidStart.map(to: true),
      sessionListener.sessionDidStop.map(to: false)
    )
  }

  var zoomFactor: Float {
    return videoKit.videoZoomFactor
  }

  func set(zoomFactor: Float) {
    videoKit.videoZoomFactor = min(4.0, zoomFactor)
  }

  var previewLayer: CALayer {
    return videoKit.previewLayer
  }

  var devicePosition: DevicePosition {
    switch videoKit.devicePosition {
    case .front: return .front
    case .back: return .back
    case .unspecified: return .back
    @unknown default: return .back
    }
  }

  func configure() -> Single<Void> {
    return Single.deferred { [videoKit] in
      videoKit.videoConfiguration.aspectRatio = .square
      return Single.just(Void())
    }
  }

  func startRunning(
    arg1: Type1,
    arg2: Type2
  ) -> Single<Void> {
    return requestPermissions()
      .subscribeOn(backgroundScheduler)
      .flatMap { [weak self] granted in
        guard let `self` = self else {
          return Single.never()
        }

        if granted {
          return self.launchVideo()
        } else {
          return Single.error(CaptureError.permissionsDenied)
        }
      }
      .logDebug("Start Running")
  }

  /// Launch AV session
  /// In case when `startRunning` and `stopRunning` methods are called very frequent
  /// the internal session doesn't have time to properly deallocate.
  /// Then we retry launching the video till previous session deallocate.
  /// - Returns: A `Single` that emits a `success` event after the session successfully launches.
  private func launchVideo() -> Single<Void> {
    let startVideoKit = Single<Void>.deferred { [videoKit] in
      try videoKit.start()
      return Single.just(Void())
    }

    return startVideoKit
      .retryWhen { [backgroundScheduler] errorNotification in
        return errorNotification
          .filter { error in
            guard let nextLevelError = error as? NextLevelError, case .started = nextLevelError else {
              return false
            }

            return true
          }
          .flatMap { [weak self] _ in self?.stopRunning() ?? .never() }
          .delay(.milliseconds(Constants.retryDelay), scheduler: backgroundScheduler)
      }
  }

  func stopRunning() -> Single<Void> {
    return Single.deferred { [videoKit] in
      videoKit.stop()
      return .just(Void())
      }
      .logDebug("Stop Running")
  }

  func startRecording() -> Single<Void> {
    let setupSession = Single<Void>.deferred { [videoKit, sessionListener] in
      guard let session = videoKit.session else {
        throw CaptureError.internalError("Capture session is not configured yet")
      }

      if session.isVideoSetup {
        return Single.just(Void())
      } else {
        return sessionListener.didSetupVideo.take(1).asSingle()
      }
    }

    let record = Single<Void>.deferred { [videoKit] in
      videoKit.record()
      return Single.just(Void())
    }

    return setupSession
      .flatMap { record }
      .subscribeOn(backgroundScheduler)
      .logDebug("Start Recording")
  }

  func stopRecording() -> Single<(String, CMTime)> {
    let pauseRecording = Single<(URL, CMTime)>.create { [videoKit] send -> Disposable in
      videoKit.pause {
        guard
          let clip = videoKit.session?.clips.last,
          let url = clip.url
        else {
          send(.error(CaptureError.internalError("Couldn't generate clip")))
          return
        }

        send(.success((url, clip.duration)))
      }

      return Disposables.create()
    }

    let copyRecordedFile: (URL, CMTime) -> Single<(String, CMTime)> = { tempURL, duration in
      return Single.deferred {
        let newURL = Clip.makeNewURL()
        try FileManager.default.copyItem(at: tempURL, to: newURL)
        return Single.just((newURL.lastPathComponent, duration))
      }
    }

    return pauseRecording
      .flatMap(copyRecordedFile)
      .subscribeOn(backgroundScheduler)
      .logDebug("Stop Recording")
  }

  private func requestPermissions() -> Single<Bool> {
    return Single.deferred {
      let dispatchGroup = DispatchGroup()

      var hasGrantedVideoAccess = false
      var hasGrantedAudioAccess = false

      dispatchGroup.enter()
      AVCaptureDevice.requestAccess(for: .video) { granted in
        hasGrantedVideoAccess = granted
        dispatchGroup.leave()
      }

      dispatchGroup.enter()
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        hasGrantedAudioAccess = granted
        dispatchGroup.leave()
      }

      dispatchGroup.wait()

      return .just(hasGrantedVideoAccess && hasGrantedAudioAccess)
    }
  }

  func switchCamera() -> Single<Void> {
    return Single.deferred { [videoKit, sessionListener] in
      videoKit.flipCaptureDevicePosition()
      return sessionListener.didChangeDeviceOrientation.take(1).asSingle()
    }
  }

  var isLightningActive: Observable<Bool> {
    return sessionListener.isLightningActive.asObservable()
  }

  func toggleLightning() {
    videoKit.torchMode = videoKit.torchMode == .off ? .on : .off
  }
}

