//
//  JCChatViewController+MessageExtensions.swift
//  IMKit
//
//  Created by mars on 2021/12/21.
//

import UIKit
import JMessage
import YHPhotoKit
import MobileCoreServices
import IQKeyboardManagerSwift

// MARK: - JMSGMessage Delegate
extension JCChatViewController: JMessageDelegate {
    func _updateBadge() {
        JMSGConversation.allConversations { (result, _) in
            guard let conversations = result as? [JMSGConversation] else {
                return
            }
            let count = conversations.unreadCount
//            if count == 0 {
//                self.leftButton.setTitle("会话", for: .normal)
//            } else {
//                self.leftButton.setTitle("会话(\(count))", for: .normal)
//            }
        }
    }

    public func onReceive(_ message: JMSGMessage!, error: Error!) {
        if error != nil {
            return
        }

        let message = _parseMessage(message)
        if messages.contains(where: { (m) -> Bool in
            return m.msgId == message.msgId
        }) {
            let indexs = chatView.indexPathsForVisibleItems
            for index in indexs {
                var m = messages[index.row]
                if !m.msgId.isEmpty {
                    m = _parseMessage(peer.conversation.message(withMessageId: m.msgId)!, false)
                    chatView.update(m, at: index.row)
                }
            }
            return
        }

        messages.append(message)
        chatView.append(message)
        updateUnread([message])
        peer.conversation.clearUnreadCount()
        if !chatView.isRoll {
            chatView.scrollToLast(animated: true)
        }
        _updateBadge()
    }

    public func onSendMessageResponse(_ message: JMSGMessage!, error: Error!) {
        if error != nil {
            printLog("@+++++++++> \(#function) sendMsg failed: \(error)")
        } else {
            printLog("@+++++++++> \(#function) sendMsg success: \(messages)")
        }
        if let error = error as NSError? {
            if error.code == 803009 {
                MBProgressHUDJChat.show(text: "发送失败，消息中包含敏感词", view: view, 2.0)
            }
            if error.code == 803005 {
                MBProgressHUDJChat.show(text: "您已不是群成员", view: view, 2.0)
            }
        }
        if let index = messages.index(message) {
            let msg = messages[index]
            msg.options.state = message.ex.state
            chatView.update(msg, at: index)
            jMessageCount += 1
        }
    }

    public func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
        if let index = messages.index(retractEvent.retractMessage) {
            let msg = _parseMessage(retractEvent.retractMessage, false)
            messages[index] = msg
            chatView.update(msg, at: index)
        }
    }

    public func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
        let msgs = offlineMessages.sorted(by: { (m1, m2) -> Bool in
            return m1.timestamp.intValue < m2.timestamp.intValue
        })
        for item in msgs {
            let message = _parseMessage(item)
            messages.append(message)
            chatView.append(message)
            updateUnread([message])
            conversation.clearUnreadCount()
            if !chatView.isRoll {
                chatView.scrollToLast(animated: true)
            }
        }
        _updateBadge()
    }

    public func onReceive(_ receiptEvent: JMSGMessageReceiptStatusChangeEvent!) {
        for message in receiptEvent.messages! {
            if let index = messages.index(message) {
                let msg = messages[index]
                msg.unreadCount = message.getUnreadCount()
                chatView.update(msg, at: index)
            }
        }
    }
}

// MARK: - JCEmoticonInputViewDataSource & JCEmoticonInputViewDelegate
extension JCChatViewController: JCEmoticonInputViewDataSource, JCEmoticonInputViewDelegate {

    open func numberOfEmotionGroups(in emoticon: JCEmoticonInputView) -> Int {
        return _emoticonGroups.count - 1
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, emotionGroupForItemAt index: Int) -> JCEmoticonGroup {
        return _emoticonGroups[index]
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, numberOfRowsForGroupAt index: Int) -> Int {
        return _emoticonGroups[index].rows
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, numberOfColumnsForGroupAt index: Int) -> Int {
        return _emoticonGroups[index].columns
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, moreViewForGroupAt index: Int) -> UIView? {
        if _emoticonGroups[index].type.isSmall {
            return _emoticonSendBtn
        } else {
            return nil
        }
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, insetForGroupAt index: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12, left: 10, bottom: 12 + 24, right: 10)
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, didSelectFor item: JCEmoticon) {
        if item.isBackspace {
            toolbar.deleteBackward()
            return
        }
        if let emoticon = item as? JCCEmoticonLarge {
            send(forLargeEmoticon: emoticon)
            return
        }
        if let code = item.contents as? String {
            return toolbar.insertText(code)
        }
        if let image = item.contents as? UIImage {
            let d = toolbar.font?.descender ?? 0
            let h = toolbar.font?.lineHeight ?? 0
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: d, width: h, height: h)
            toolbar.insertAttributedText(NSAttributedString(attachment: attachment))
            return
        }
    }
}

// MARK: - SAIToolboxInputViewDataSource & SAIToolboxInputViewDelegate
extension JCChatViewController: SAIToolboxInputViewDataSource, SAIToolboxInputViewDelegate {

    open func numberOfToolboxItems(in toolbox: SAIToolboxInputView) -> Int {
        return _toolboxItems.count
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, toolboxItemForItemAt index: Int) -> SAIToolboxItem {
        return _toolboxItems[index]
    }

    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfRowsForSectionAt index: Int) -> Int {
        return 2
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfColumnsForSectionAt index: Int) -> Int {
        return 4
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, insetForSectionAt index: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12, left: 10, bottom: 12, right: 10)
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, shouldSelectFor item: SAIToolboxItem) -> Bool {
        return true
    }
    private func _pushToSelectPhotos() {
        PhotoChoiceHandler.default.photo(target: self) { [weak self] photos in
            for item in photos {
                guard let photo = item as? UIImage else {
                    return
                }
                DispatchQueue.main.async {
                    self?.send(forImage: photo)
                }
            }
        }
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, didSelectFor item: SAIToolboxItem) {
        inputItem = nil
        toolbar.resignFirstResponder()
        switch item.identifier {
        case "page:pic":
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    DispatchQueue.main.sync {
                        if status != .authorized {
                            JCAlertView.bulid().setTitle("无权限访问照片").setMessage("请在设备的设置-极光 IM中允许访问照片。").setDelegate(self).addCancelButton("好的").addButton("去设置").setTag(10001).show()
                        } else {
                            self._pushToSelectPhotos()
                        }
                    }
                })
            } else {
                _pushToSelectPhotos()
            }
        case "page:camera":
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
        case "page:video_s":
            videoPicker.modalPresentationStyle = .fullScreen
            present(videoPicker, animated: true, completion: nil)
        case "page:location":
            break
//            TODO: FXJ CHECK CODE
//            let vc = JCAddMapViewController()
//            vc.addressBlock = { (dict: Dictionary?) in
//                if dict != nil {
//                    let lon = Float(dict?["lon"] as! String)
//                    let lat = Float(dict?["lat"] as! String)
//                    let address = dict?["address"] as! String
//                    self.send(address: address, lon: NSNumber(value: lon!), lat: NSNumber(value: lat!))
//                }
//            }
//            navigationController?.pushViewController(vc, animated: true)
        case "page:businessCard":
            let vc = FriendsBusinessCardViewController()
            vc.conversation =  peer.conversation
            let nav = JCNavigationController(rootViewController: vc)
            present(nav, animated: true, completion: {
                self.toolbar.isHidden = true
            })
        default:
            self.expandToolbox(toolbox, didSelectFor: item)
            break
        }
    }

    open override func
        present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension JCChatViewController: JCChatViewDelegate {
    public func refershChatView( chatView: JCChatView) {
        messagePage += 1
        _loadMessage(messagePage)
        chatView.stopRefresh()
    }

    public func deleteMessage(message: JCMessageType) {
        peer.conversation.deleteMessage(withMessageId: message.msgId)
        if let index = messages.index(message) {
            jMessageCount -= 1
            messages.remove(at: index)
            if let message = messages.last {
                if message.content is JCMessageTimeLineContent {
                    messages.removeLast()
                    chatView.remove(at: messages.count)
                }
            }
        }
    }

    public func forwardMessage(message: JCMessageType) {
        if let message =  peer.conversation.message(withMessageId: message.msgId) {
            let vc = JCForwardViewController()
            vc.message = message
            let nav = JCNavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: {
                self.toolbar.isHidden = true
            })
        }
    }

    public func withdrawMessage(message: JCMessageType) {
        guard let message =  peer.conversation.message(withMessageId: message.msgId) else {
            return
        }
        JMSGMessage.retractMessage(message, completionHandler: { (_, error) in
            if error == nil {
                if let index = self.messages.index(message) {
                    let msg = self._parseMessage(self.peer.conversation.message(withMessageId: message.msgId)!, false)
                    self.messages[index] = msg
                    self.chatView.update(msg, at: index)
                }
            } else {
                MBProgressHUDJChat.show(text: "发送时间过长，不能撤回", view: self.view)
            }
        })
    }

    public func indexPathsForVisibleItems(chatView: JCChatView, items: [IndexPath]) {
        for item in items {
            if item.row <= minIndex {
                var msgs: [JCMessage] = []
                for index in item.row...minIndex {
                    if index < messages.count {
                        msgs.append(messages[index])
                    }
                }
                updateUnread(msgs)
                minIndex = item.row
            }
        }
    }

    internal func updateUnread(_ messages: [JCMessage]) {
        for message in messages {
            if message.options.alignment != .left {
                continue
            }
            if let msg =  peer.conversation.message(withMessageId: message.msgId) {
                if msg.isHaveRead {
                    continue
                }
                msg.setMessageHaveRead({ _, _  in
                })
            }
        }
    }
}

// MARK: - SAIInputBarDelegate & SAIInputBarDisplayable
extension JCChatViewController: SAIInputBarDelegate, SAIInputBarDisplayable {

    open override var inputAccessoryView: UIView? {
        return toolbar
    }
    open var scrollView: SAIInputBarScrollViewType {
        return chatView
    }
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open func inputView(with item: SAIInputItem) -> UIView? {
        if let view = inputViews[item.identifier] {
            return view
        }
        printLog("inputItem: @++++> \(item.identifier)")
        switch item.identifier {
        case "kb:emoticon":
            let view = JCEmoticonInputView()
            view.delegate = self
            view.dataSource = self
            inputViews[item.identifier] = view
            return view
        case "kb:toolbox":
            let view = SAIToolboxInputView()
            view.delegate = self
            view.dataSource = self
            inputViews[item.identifier] = view
            return view
        default:
            return nil
        }
    }

    open func inputViewContentSize(_ inputView: UIView) -> CGSize {
        return CGSize(width: view.frame.width, height: 238)
    }

    public func inputBar(_ inputBar: SAIInputBar, shouldDeselectFor item: SAIInputItem) -> Bool {
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, shouldSelectFor item: SAIInputItem) -> Bool {
        if item.identifier == "kb:audio" {
            return true
        }
        if item.identifier == "kb:keyboard" {
            return true
        }
        guard let _ = inputView(with: item) else {
            if item.identifier == "kb:close_x" {
                view.endEditing(true)
                inputItem = nil
                toolbar.resignFirstResponder()
            }
            return false
        }
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, didSelectFor item: SAIInputItem) {
        inputItem = item

        if item.identifier == "kb:audio" {
            inputBar.deselectBarAllItem()
            return
        }
//        if item.identifier == "kb:close_x" {
//            return
//        }
        if item.identifier == "kb:keyboard" {
            inputBar.setInputMode(.editing, animated: true)
            return
        }
        if let kb = inputView(with: item) {
            inputBar.setInputMode(.selecting(kb), animated: true)
        }
    }
    open func inputBar(didChangeMode inputBar: SAIInputBar) {
        if inputItem?.identifier == "kb:audio" {
            return
        }
        if let item = inputItem, !inputBar.inputMode.isSelecting {
            inputBar.deselectBarItem(item, animated: true)
        }
    }

    open func inputBar(didChangeText inputBar: SAIInputBar) {
        _emoticonSendBtn.isEnabled = inputBar.attributedText.length != 0
    }

    public func inputBar(shouldReturn inputBar: SAIInputBar) -> Bool {
        if inputBar.attributedText.length == 0 {
            return false
        }
        send(forText: inputBar.attributedText)
        inputBar.attributedText = nil
        return false
    }

    public func inputBar(_ inputBar: SAIInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentIndex = range.location
        if !isGroup {
            return true
        }
        if string == "@" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                let vc = JCRemindListViewController()
                vc.finish = { (user, isAtAll, length) in
                    self.handleAt(inputBar, range, user, isAtAll, length)
                }
                vc.group = self.peer.conversation.target as! JMSGGroup
                let nav = JCNavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {})
            }
        } else {
            return updateRemids(inputBar, string, range, currentIndex)
        }
        return true
    }

    public func inputBar(touchDown recordButton: UIButton, inputBar: SAIInputBar) {
        if recordingHub != nil {
            recordingHub.removeFromSuperview()
        }
        recordingHub = JCRecordingView(frame: CGRect.zero)
        recordHelper.updateMeterDelegate = recordingHub
        recordingHub.startRecordingHUDAtView(view)
        recordingHub.frame = CGRect(x: view.tz_centerX - 70, y: view.tz_centerY - 70, width: 136, height: 136)
        recordHelper.startRecordingWithPath(String.getRecorderPath()) {
        }
    }

    public func inputBar(dragInside recordButton: UIButton, inputBar: SAIInputBar) {
        recordingHub.pauseRecord()
    }

    public func inputBar(dragOutside recordButton: UIButton, inputBar: SAIInputBar) {
        recordingHub.resaueRecord()
    }

    public func inputBar(touchUpInside recordButton: UIButton, inputBar: SAIInputBar) {
        if recordHelper.recorder ==  nil {
            return
        }
        recordHelper.finishRecordingCompletion()
        if (recordHelper.recordDuration! as NSString).floatValue < 1 {
            recordingHub.showErrorTips()
            let time: TimeInterval = 1.5
            let hub = recordingHub
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                hub?.removeFromSuperview()
            }
            return
        } else {
            recordingHub.removeFromSuperview()
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
    }

    public func inputBar(touchUpOutside recordButton: UIButton, inputBar: SAIInputBar) {
        recordHelper.cancelledDeleteWithCompletion()
        recordingHub.removeFromSuperview()
    }
    
    public func inputBar(didEndEditing inputBar: SAIInputBar) {
        printLog("\(#function)")
    }
}
