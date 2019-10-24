//
//  MessageInputView.swift
//  YazaKit
//
//  Created by Oleksii Andriushchenko on 8/10/19.
//  Copyright © 2019 Uptech. All rights reserved.
//

import Foundation

protocol MessageInputViewDelegate: class {
  func messageInputViewDidBecomeActive(_ messageInputViewView: MessageInputView)
  func messageInputDidBecomeInactive(_ messageInputViewView: MessageInputView)
  func messageInputView(_ messageInputView: MessageInputView, didSendText text: String)
}

final class MessageInputView: UIView {

  private let textField = UITextField()
  private let sendButton = UIButton()

  weak var delegate: MessageInputViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    // configure view
    layer.cornerRadius = 12
    layer.borderWidth = 1
    layer.borderColor = UIColor.buttonsTextAndIcons.cgColor

    // configure text field
    textField.delegate = self
    textField.attributedPlaceholder = NSAttributedString(
      string: "Send message...",
      attributes: [
        .foregroundColor: UIColor.iconsNonactive,
        .font: UIFont.systemFont(ofSize: 15)
      ]
    )
    textField.textColor = .buttonsTextAndIcons
    textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    addSubview(textField, constraints: [
      textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      textField.bottomAnchor.constraint(equalTo: bottomAnchor),
      textField.centerYAnchor.constraint(equalTo: centerYAnchor),
      textField.heightAnchor.constraint(equalToConstant: 40)
    ])

    // configure send button
    sendButton.isEnabled = false
    sendButton.setTitle("Send", for: .normal)
    sendButton.setTitleColor(.buttonsTextAndIcons, for: .normal)
    sendButton.setTitleColor(.iconsNonactive, for: .disabled)
    sendButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    sendButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    addSubview(sendButton, constraints: [
      sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16),
      sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      sendButton.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  func activateTextField() {
    textField.becomeFirstResponder()
  }

  @objc private func editingChanged() {
    guard let text = textField.text else {
      return
    }
    sendButton.isEnabled = !text.isEmpty
  }

  @objc private func handleTap() {
    textFieldShouldReturn(textField)
  }
}

extension MessageInputView: UITextFieldDelegate {

  func textFieldDidBeginEditing(_ textField: UITextField) {
    delegate?.messageInputViewDidBecomeActive(self)
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    delegate?.messageInputDidBecomeInactive(self)
    textField.text = ""
  }

  @discardableResult
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    defer { textField.resignFirstResponder() }
    guard let text = textField.text, !text.isEmpty else {
      return true
    }
    delegate?.messageInputView(self, didSendText: text)
    return true
  }
}
