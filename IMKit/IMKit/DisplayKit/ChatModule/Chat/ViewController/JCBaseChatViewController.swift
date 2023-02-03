//
//  JCBaseChatViewController.swift
//  IMKit
//
//  Created by mars on 2021/12/22.
//

import UIKit

open class JCBaseChatViewController: IMBaseViewController {
    public class ChatCustomConfig {
        public var customParseMessageHandle: (JMSGCustomContent) -> JCMessage? = { _ in
            return .none
        }
        public var messageOptionConfig: (JCMessage) -> JCMessage = { return $0 }
    }
    public var customConfig = ChatCustomConfig()
    internal var myAvator: UIImage?
    lazy var messages: [JCMessage] = []
    internal let currentUser = JMSGUser.myInfo()
    internal var messagePage = 0
    internal var maxTime = 0
    internal var minTime = 0
    internal var minIndex = 0
    internal var jMessageCount = 0
    internal var isFristLaunch = true
    internal var isGroup = false
    public let peer: Peer

    internal var draft: String?
    public lazy var toolbar: SAIInputBar = {
        let bar = SAIInputBar(type: .default)
        bar.adaptInputBarHandle = { [unowned self] in
            self.updateBar(newModel: $1, bar: $0)
        }
        return bar
    }()
    internal lazy var inputViews: [String: UIView] = [:]
    internal weak var inputItem: SAIInputItem?
    var chatViewLayout: JCChatViewLayout = .init()
    var chatView: JCChatView!
    internal lazy var reminds: [JCRemind] = []
    internal lazy var documentInteractionController = UIDocumentInteractionController()

    internal var recordingHub: JCRecordingView!
    internal lazy var recordHelper: JCRecordVoiceHelper = {
        let recordHelper = JCRecordVoiceHelper()
        recordHelper.delegate = self
        return recordHelper
    }()

    required public init(peer: Peer) {
//        self.conversation = peer.conversation
        self.peer = peer
        super.init(nibName: nil, bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
        if let draft = JCDraft.getDraft(peer.conversation) {
            self.draft = draft
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        peer.conversation.clearUnreadCount()
        // Do any additional setup after loading the view.
    }

    open var expandToolBoxItems: [SAIToolboxItem]? {
        return .none
    }

    internal lazy var _toolboxItems: [SAIToolboxItem] = {
        var toolBoxItems = [
            SAIToolboxItem("page:pic", "照片", ThemeManager.instance.loadImage("chat_photo_icon", .default)),
            SAIToolboxItem("page:camera", "拍摄", ThemeManager.instance.loadImage("chat_camera_icon", .default)),
            ]
        if let expands = expandToolBoxItems {
            toolBoxItems.append(contentsOf: expands)
        }
        return toolBoxItems
    }()

    open func expandToolbox(_ toolbox: SAIToolboxInputView, didSelectFor item: SAIToolboxItem) {
    }
    
    open func tapAvatarView(message: JCMessageType) {
        toolbar.resignFirstResponder()
    }
}

internal extension JCBaseChatViewController {
    func _setupNavigation() {
//        let navButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
//        if isGroup {
//            navButton.setImage(UIImage.init(named:"group_icon"), for: .normal)
//            navButton.addTarget(self, action: #selector(_getGroupInfo), for: .touchUpInside)
//            let item1 = UIBarButtonItem(customView: navButton)
//            navigationItem.rightBarButtonItems =  [item1]
//        } else {
//            navButton.setImage(UIImage.init(named:"com_back"), for: .normal)
//            navButton.addTarget(self, action: #selector(_getSingleInfo), for: .touchUpInside)
//        }
//        let item1 = UIBarButtonItem(customView: navButton)
//        navigationItem.rightBarButtonItems =  [item1]

//        let item2 = UIBarButtonItem(customView: leftButton)
//        navigationItem.leftBarButtonItems =  [item2]
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

internal extension JCBaseChatViewController {
    func isNeedInsertTimeLine(_ time: Int) -> Bool {
        if maxTime == 0 || minTime == 0 {
            maxTime = time
            minTime = time
            return true
        }
        if (time - maxTime) >= 5 * 60000 {
            maxTime = time
            return true
        }
        if (minTime - time) >= 5 * 60000 {
            minTime = time
            return true
        }
        return false
    }

    func _updateTitle() {
        title = peer.conversationTitle(true)
        peer.conversationTitle(true) { [weak self] in
            self?.title = $0
        }
    }

    // MARK: - parse message
    func _parseMessage(_ message: JMSGMessage, _ isNewMessage: Bool = true) -> JCMessage {
        if isNewMessage {
            jMessageCount += 1
        }
        return message.parseMessage(self, { [weak self] (message, data) in
            self?.updateMediaMessage(message, data: data)
        }, customHandle: customConfig.customParseMessageHandle, optionsConfig: customConfig.messageOptionConfig)
    }

    func _loadMessage(_ page: Int) {
        printLog("\(page)")
        let messages = peer.conversation.messageArrayFromNewest(withOffset: NSNumber(value: jMessageCount), limit: NSNumber(value: 17))
        if messages.count == 0 {
            return
        }
        var msgs: [JCMessage] = []
        for index in 0..<messages.count {
            let message = messages[index]
            let msg = _parseMessage(message)
            msgs.insert(msg, at: 0)
            if isNeedInsertTimeLine(message.timestamp.intValue) || index == messages.count - 1 {
                let timeContent = JCMessageTimeLineContent(date: Date(timeIntervalSince1970: TimeInterval(message.timestamp.intValue / 1000)))
                let m = JCMessage(content: timeContent)
                m.options.showsTips = false
                msgs.insert(m, at: 0)
            }
        }
        if page != 0 {
            minIndex = minIndex + msgs.count
            chatView.insert(contentsOf: msgs, at: 0)
        } else {
            minIndex = msgs.count - 1
            chatView.append(contentsOf: msgs)
        }
        self.messages.insert(contentsOf: msgs, at: 0)
    }

    func handleAt(_ inputBar: SAIInputBar, _ range: NSRange, _ user: JMSGUser?, _ isAtAll: Bool, _ length: Int) {
        let text = inputBar.text!
        let currentIndex = range.location
        var displayName = "所有成员"

        if let user = user {
            displayName = user.displayName()
        }
        let remind = JCRemind(user, currentIndex, currentIndex + 2 + displayName.length, displayName.length + 2, isAtAll)
        if text.length == currentIndex + 1 {
            inputBar.text = text + displayName + " "
        } else {
            let index1 = text.index(text.endIndex, offsetBy: currentIndex - text.length + 1)
            let prefix = text.substring(with: (text.startIndex..<index1))
            let index2 = text.index(text.startIndex, offsetBy: currentIndex + 1)
            let suffix = text.substring(with: (index2..<text.endIndex))
            inputBar.text = prefix + displayName + " " + suffix
            _ = self.updateRemids(inputBar, "@" + displayName + " ", range, currentIndex)
        }
        self.reminds.append(remind)
        self.reminds.sort(by: { (r1, r2) -> Bool in
            return r1.startIndex < r2.startIndex
        })
    }

    func updateRemids(_ inputBar: SAIInputBar, _ string: String, _ range: NSRange, _ currentIndex: Int) -> Bool {
        for index in 0..<reminds.count {
            let remind = reminds[index]
            let length = remind.length
            let startIndex = remind.startIndex
            let endIndex = remind.endIndex
            // Delete
            if currentIndex == endIndex - 1 && string.length == 0 {
                for _ in 0..<length {
                    inputBar.deleteBackward()
                }
                // Move Other Index
                for subIndex in (index + 1)..<reminds.count {
                    let subTemp = reminds[subIndex]
                    subTemp.startIndex -= length
                    subTemp.endIndex -= length
                }
                reminds.remove(at: index)
                return false
            } else if currentIndex > startIndex && currentIndex < endIndex {
                // Delete Content
                if string.length == 0 {
                    for subIndex in (index + 1)..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex -= 1
                        subTemp.endIndex -= 1
                    }
                    reminds.remove(at: index)
                    return true
                }
                // Add Content
                else {
                    for subIndex in (index + 1)..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex += string.length
                        subTemp.endIndex += string.length
                    }
                    reminds.remove(at: index)
                    return true
                }
            }
        }
        for index in 0..<reminds.count {
            let tempDic = reminds[index]
            let startIndex = tempDic.startIndex
            if currentIndex <= startIndex {
                if string.count == 0 {
                    for subIndex in index..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex -= 1
                        subTemp.endIndex -= 1
                    }
                    return true
                } else {
                    for subIndex in index..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex += string.length
                        subTemp.endIndex += string.length
                    }
                    return true
                }
            }
        }
        return true
    }
}

extension JCBaseChatViewController {
    @objc func _reloadMessage() {
        _removeAllMessage()
        messagePage = 0
        _loadMessage(messagePage)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.chatView.scrollToLast(animated: false)
        }
    }

    @objc func _removeAllMessage() {
        jMessageCount = 0
        messages.removeAll()
        chatView.removeAll()
    }

    @objc func _tapView() {
        view.endEditing(true)
        inputItem = nil
        toolbar.resignFirstResponder()
    }

    @objc func _back() {
        navigationController?.popViewController(animated: true)
    }
}

extension JCBaseChatViewController {
    // MARK: - send message
    public func send(_ message: JCMessage, _ jmessage: JMSGMessage) {
        if isNeedInsertTimeLine(jmessage.timestamp.intValue) {
            let timeContent = JCMessageTimeLineContent(date: Date(timeIntervalSince1970: TimeInterval(jmessage.timestamp.intValue / 1000)))
            let m = JCMessage(content: timeContent)
            m.options.showsTips = false
            messages.append(m)
            chatView.append(m)
        }
        message.msgId = jmessage.msgId
        message.name = currentUser.displayName()
        message.senderAvator = myAvator
        message.sender = currentUser
        message.options.alignment = .right
        message.options.state = .sending
        if let group = peer.conversation.target as? JMSGGroup {
            message.targetType = .group
            message.unreadCount = group.memberArray().count - 1
        } else {
            message.targetType = .single
            message.unreadCount = 1
        }
        message.contentType = message.content.contentType
        var cMsg = self.customConfig.messageOptionConfig(message)
        chatView.append(cMsg)
        messages.append(cMsg)
        chatView.scrollToLast(animated: false)
        peer.conversation.send(jmessage, optionalContent: JMSGOptionalContent.ex.default)
    }

    func send(forText text: NSAttributedString) {
        let message = JCMessage(content: JCMessageTextContent(attributedText: text))
        let content = JMSGTextContent(text: text.string)
        let msg = JMSGMessage.ex.createMessage(peer.conversation, content, reminds)
        reminds.removeAll()
        send(message, msg)
    }

    func send(forLargeEmoticon emoticon: JCCEmoticonLarge) {
        guard let image = emoticon.contents as? UIImage else {
            return
        }
        let messageContent = JCMessageImageContent()
        messageContent.image = image
        messageContent.delegate = self
        let message = JCMessage(content: messageContent)

        let content = JMSGImageContent(imageData: image.pngData()!)
        let msg = JMSGMessage.ex.createMessage(peer.conversation, content!, nil)
        msg.ex.isLargeEmoticon = true
        message.options.showsTips = false
        send(message, msg)
    }

    func send(forImage image: UIImage) {
        let data = image.jpegData(compressionQuality: 1.0)!
        let content = JMSGImageContent(imageData: data)

        let message = JMSGMessage.ex.createMessage(peer.conversation, content!, nil)
        let imageContent = JCMessageImageContent()
        imageContent.delegate = self
        imageContent.image = image
        content?.uploadHandler = {  (percent: Float, _: (String?)) -> Void in
            imageContent.upload?(percent)
        }
        let msg = JCMessage(content: imageContent)
        send(msg, message)
    }

    func send(voiceData: Data, duration: Double) {
        let voiceContent = JCMessageVoiceContent()
        voiceContent.data = voiceData
        voiceContent.duration = duration
        voiceContent.delegate = self
        let content = JMSGVoiceContent(voiceData: voiceData, voiceDuration: NSNumber(value: duration))
        let message = JMSGMessage.ex.createMessage(peer.conversation, content, nil)

        let msg = JCMessage(content: voiceContent)
        send(msg, message)
    }
    func send(videoData: Data, thumbData: Data, duration: Double, format: String) {
        let time = NSNumber(value: duration)
        let content = JMSGVideoContent(videoData: videoData, thumbData: thumbData, duration: time)
        content.format = format
        let message = JMSGMessage.ex.createMessage(peer.conversation, content, nil)

        let videoContent = JCMessageVideoContent()
        videoContent.videoContent = content
        videoContent.data = videoData
        videoContent.image = UIImage(data: thumbData)
        videoContent.delegate = self

        let msg = JCMessage(content: videoContent)
        send(msg, message)
    }
    func send(fileData: Data, fileName: String) {
        let videoContent = JCMessageVideoContent()
        videoContent.data = fileData
        videoContent.delegate = self

        let content = JMSGFileContent(fileData: fileData, fileName: fileName)
        let message = JMSGMessage.ex.createMessage(peer.conversation, content, nil)
        let msg = JCMessage(content: videoContent)
        send(msg, message)
    }

    func send(address: String, lon: NSNumber, lat: NSNumber) {
        let locationContent = JCMessageLocationContent()
        locationContent.address = address
        locationContent.lat = lat.doubleValue
        locationContent.lon = lon.doubleValue
        locationContent.delegate = self

        let content = JMSGLocationContent(latitude: lat, longitude: lon, scale: NSNumber(value: 1), address: address)
        let message = JMSGMessage.ex.createMessage(peer.conversation, content, nil)
        let msg = JCMessage(content: locationContent)
        send(msg, message)
    }
}

// Helper function inserted by Swift 4.2 migrator.
internal func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
internal func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

public extension JCBaseChatViewController {
    public func sendCustomMessage(_ customMessage: ChatMessageReadable) {
        self.navigationController?.popToViewController(self, animated: true)
        let chatBody = customMessage.chatMsgBody
        printLog(customMessage.chatMsgBody.description)
        guard let cMessage = customConfig.customParseMessageHandle(chatBody) else {
            return
        }

        let message = JMSGMessage.ex.createMessage(peer.conversation, chatBody, nil)
        send(cMessage, message)
    }
}

extension JCBaseChatViewController {
    func updateBar(newModel: SAIInputMode, bar: SAIInputBar) {
//        bar.setBarItems(leftBarItems(newMode: newModel), atPosition: .left)
        bar.setBarItems(rightBarItems(newMode: newModel), atPosition: .right, animated: false)
    }
    
    func leftBarItems(newMode: SAIInputMode) -> [SAIInputItem] {
        return []
    }
    
    func rightBarItems(newMode: SAIInputMode) -> [SAIInputItem] {
        guard let keyIdentifier = inputItem?.identifier else {
            return [SAIInputItem.create("kb:emoticon", "YH_KB_Emotion", "YH_KB_Emotion"),
                    SAIInputItem.create("kb:toolbox", "YH_KB_More", "YH_KB_More")]
        }
        printLog("rightBarItems -> \(keyIdentifier)")
        
        if keyIdentifier == "kb:toolbox" {
            return [SAIInputItem.create("kb:emoticon", "YH_KB_Emotion", "YH_KB_Emotion"),
                    SAIInputItem.create("kb:close_x", "chat_keyboard_close_x", "chat_keyboard_close_x")]
        }
        if keyIdentifier == "kb:emoticon" {
            return [SAIInputItem.create("kb:keyboard", "YH_KB_Keyboard", "YH_KB_Keyboard"),
                    SAIInputItem.create("kb:toolbox", "YH_KB_More", "YH_KB_More")]
        }

        return [SAIInputItem.create("kb:emoticon", "YH_KB_Emotion", "YH_KB_Emotion"),
                SAIInputItem.create("kb:toolbox", "YH_KB_More", "YH_KB_More")]
    }
}

extension SAIInputItem {
    static func create(_ identifier: String, _ nName: String, _ hName: String) -> SAIInputItem {
        let item = SAIInputItem()

        item.identifier = identifier
        item.size = CGSize(width: 34, height: 34)

        let nImage = UIImage.loadImage(nName)
        let hImage = UIImage.loadImage(hName)
        item.setImage(nImage, for: [.normal])
        item.setImage(hImage, for: [.highlighted])
        item.setImage(hImage, for: [.selected, .normal])
        return item
    }
}
