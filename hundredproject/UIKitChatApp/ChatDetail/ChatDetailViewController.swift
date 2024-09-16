//
//  ChatDetailViewController.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import InputBarAccessoryView
import MessageKit
import UIKit

final class ChatDetailViewController: MessagesViewController {
    lazy var messageList: [ChatMessage] = []
    
    @objc
    func loadMoreMessages() {}
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChatNetworkManager.instance.delegate = self
        ChatNetworkManager.instance.connect(
            room: UIKitChatSaveInfo.instance.chatRoom,
            name: UIKitChatSaveInfo.instance.username
        )
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ChatNetworkManager.instance.disconnect()
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnInputBarHeightChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        messagesCollectionView.refreshControl = refreshControl
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .gray
        messageInputBar.sendButton.setTitleColor(.gray, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.blue.withAlphaComponent(0.3),
            for: .highlighted)
    }
    
    func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
          
//          SampleData.shared.getMessages(count: count) { messages in
//            DispatchQueue.main.async {
//              self.messageList = messages
//              self.messagesCollectionView.reloadData()
//              self.messagesCollectionView.scrollToLastItem(animated: false)
//            }
//          }
        }
      }
    
}

// MARK: - MessagesDisplayDelegate
extension ChatDetailViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and _: MessageType, at _: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .green : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return .zero
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatDetailViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func cellBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        return 10
    }
//
//    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return CGSize(width: 0, height: 8)
//    }
//    
//    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return CGSize(width: 0, height: 8)
//    }
}

// MARK: - MessagesDataSource
extension ChatDetailViewController: MessagesDataSource {
    var currentSender: any MessageKit.SenderType {
        return UserSender(senderId: UIKitChatSaveInfo.instance.chatRoom + UIKitChatSaveInfo.instance.username, 
                          displayName: UIKitChatSaveInfo.instance.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in: MessagesCollectionView) -> any MessageType {
        messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messageList.count
    }
    
    func messageBottomLabelAttributedText(for message: any MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
                        string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                        attributes: [
                            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1176470588, green: 0.4470588235, blue: 0.8, alpha: 1)])
    }
    
    func messageTopLabelAttributedText(for message: any MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if message.sender.senderId == currentSender.senderId {
            return nil
        }
        return NSAttributedString(
                        string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                        attributes: [
                            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1176470588, green: 0.4470588235, blue: 0.8, alpha: 1)])
    }
}

extension ChatDetailViewController: MessageCellDelegate {}

// MARK: - InputBarAccessoryViewDelegate
extension ChatDetailViewController: InputBarAccessoryViewDelegate {
    @objc
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        processInputBar(messageInputBar)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? "-")
        }
        
        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.sendMessage(components)
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
}

// MARK: - view and logic interpolation
extension ChatDetailViewController {
    private func insertMessage(_ message: ChatMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    private func sendMessage(_ data: [Any]) {
        for component in data {
            let user = currentSender
            if let str = component as? String {
                let message = ChatMessage(sender: user, messageId: UUID().uuidString, sentDate: Date(), kind: .text(str))
                ChatNetworkManager.instance.sendMessage(message: str)
                insertMessage(message)
            }
        }
    }
    
    private func insertAnotherUserMessage(username: String, message: String) {
        let user = UserSender(senderId: UIKitChatSaveInfo.instance.chatRoom + username,
                              displayName: username)
        let messageWrapped = ChatMessage(sender: user, messageId: UUID().uuidString, sentDate: Date(), kind: .text(message))
        insertMessage(messageWrapped)
    }
}

// MARK: - ChatNetworkManagerDelegate
extension ChatDetailViewController: ChatNetworkManagerDelegate {
    func onTyping(message: String) {
    }
        
    func onConnect(message: String) {
        
    }
    
    func onDisconnect(message: String) {
        
    }
    
    func onReceiveMessage(username: String,message: String) {
        insertAnotherUserMessage(username: username, message: message)
    }
}
