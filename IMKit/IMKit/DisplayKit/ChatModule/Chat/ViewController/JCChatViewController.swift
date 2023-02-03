//
//  JCChatViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/2/28.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage
import YHPhotoKit
import MobileCoreServices
import IQKeyboardManagerSwift
/// 聊天界面
open class JCChatViewController: JCBaseChatViewController {
    required public init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    required public init(peer: Peer) {
        super.init(peer: peer)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        _init()
    }

    open override func loadView() {
        super.loadView()
        let frame = CGRect(x: 0, y: self.navigationController?.navigationBar.frame.maxY ?? 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.maxY ?? 0))
        chatView = JCChatView(frame: frame, chatViewLayout: chatViewLayout)
        chatView.delegate = self
        chatView.messageDelegate = self
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.delegate = self
        toolbar.text = draft
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolbar.isHidden = false
        IQKeyboardManager.shared.enable = false
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        inputItem = nil
        toolbar.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        if let group = peer.conversation.target as? JMSGGroup {
            self.title = String(format: "%@(%d)", group.displayName(), group.memberArray().count)
        }
//        #warning("")
//        title = "商家"
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    open override func viewWillLayoutSubviews() {
        if #available(iOS 11.0, *) {
            _emoticonSendBtn.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10 + 8, bottom: 0, right: view!.safeAreaInsets.bottom > 10.0 ? 18.0 : 8.0)
            var edge = emoticonView._tabbar.contentInset
            edge.left = 14.0
            emoticonView._tabbar.contentInset = edge
        } else {
            _emoticonSendBtn.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10 + 8, bottom: 0, right: 8.0)
        }
        super.viewWillLayoutSubviews()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        navigationController?.navigationBar.isTranslucent = false
        IQKeyboardManager.shared.enable = true
        JCDraft.update(text: toolbar.text, conversation: peer.conversation)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        JMessage.remove(self, with: peer.conversation)
    }

    internal lazy var imagePicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = self
        return picker
    }()

    internal lazy var videoPicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.sourceType = .camera
        picker.cameraCaptureMode = .video
        picker.videoMaximumDuration = 10
        picker.delegate = self
        return picker
    }()

    internal lazy var _emoticonGroups: [JCCEmoticonGroup] = {
        var groups: [JCCEmoticonGroup] = []
        if let group = JCCEmoticonGroup(identifier: "com.apple.emoji") {
            groups.append(group)
        }
        if let group = JCCEmoticonGroup(identifier: "cn.jchat.guangguang") {
            groups.append(group)
        }
        return groups
    }()
    internal lazy var _emoticonSendBtn: UIButton = {
        var button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10 + 8, bottom: 0, right: 8)
        button.setTitle("发送", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setBackgroundImage(UIImage.loadImage("chat_emoticon_btn_send_blue"), for: .normal)
        button.setBackgroundImage(UIImage.loadImage("chat_emoticon_btn_send_gray"), for: .disabled)
        button.addTarget(self, action: #selector(_sendHandler), for: .touchUpInside)
        return button
    }()
    internal lazy var emoticonView: JCEmoticonInputView = {
        let emoticonView = JCEmoticonInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 275))
        emoticonView.delegate = self
        emoticonView.dataSource = self
        return emoticonView
    }()
//
    internal lazy var toolboxView: SAIToolboxInputView = {
        var toolboxView = SAIToolboxInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 219))
        toolboxView.delegate = self
        toolboxView.dataSource = self
        return toolboxView
    }()

//    fileprivate lazy var leftButton: UIButton = {
//        let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 65 / 3))
//        leftButton.setImage(UIImage.init(named:"com_back"), for: .normal)
//        leftButton.setImage(UIImage.init(named:"com_back"), for: .highlighted)
//
//        leftButton.addTarget(self, action: #selector(_back), for: .touchUpInside)
//        leftButton.setTitle("", for: .normal)
//        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        leftButton.contentHorizontalAlignment = .left
//        return leftButton
//    }()

    private func _init() {
        myAvator = UIImage.getMyAvator()
        isGroup = peer.conversation.ex.isGroup
        _updateTitle()
        view.backgroundColor = .white
        JMessage.add(self, with: peer.conversation)
        _setupNavigation()
        _loadMessage(messagePage)
        let tap = UITapGestureRecognizer(target: self, action: #selector(_tapView))
        tap.delegate = self
        chatView.addGestureRecognizer(tap)
        view.addSubview(chatView)

        _updateBadge()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_removeAllMessage), name: NSNotification.Name(rawValue: kDeleteAllMessage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_reloadMessage), name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_updateFileMessage(_:)), name: NSNotification.Name(rawValue: kUpdateFileMessage), object: nil)
    }

    @objc func _updateFileMessage(_ notification: Notification) {
        let userInfo = notification.userInfo
        let msg = userInfo?[kUpdateFileMessage] as! JMSGMessage
        let msgId = msg.msgId
        let message = peer.conversation.message(withMessageId: msgId)!
        let content = message.content as! JMSGFileContent
        let url = URL(fileURLWithPath: content.originMediaLocalPath ?? "")
        let data = try! Data(contentsOf: url)
        updateMediaMessage(message, data: data)
    }

    @objc func keyboardFrameChanged(_ notification: Notification) {
        let dic = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardValue = dic.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let bottomDistance = UIScreen.main.bounds.size.height - keyboardValue.cgRectValue.origin.y
        let duration = Double(dic.object(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! NSNumber)

        UIView.animate(withDuration: duration, animations: {
        }) { (_) in
            if (bottomDistance == 0 || bottomDistance == self.toolbar.frame.height) && !self.isFristLaunch {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.chatView.scrollToLast(animated: false)
            }
            self.isFristLaunch = false
        }
    }

    @objc func _sendHandler() {
        let text = toolbar.attributedText
        if text != nil && (text?.length)! > 0 {
            send(forText: text!)
            toolbar.attributedText = nil
        }
    }

    @objc func _getSingleInfo() {
        let vc = JCSingleSettingViewController()
        vc.user = peer.conversation.target as? JMSGUser
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func _getGroupInfo() {
        let vc = JCGroupSettingViewController()
        let group = peer.conversation.target as! JMSGGroup
        vc.group = group
        navigationController?.pushViewController(vc, animated: true)
    }
}
