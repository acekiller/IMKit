//
//  IMConversationManager.swift
//  IMKit
//
//  Created by mars on 2021/12/27.
//

import Foundation
import RxSwift
import JMessage

open class IMConversationManager: NSObject {
    public var conversationList: BehaviorSubject<[JMSGConversation]> = BehaviorSubject<[JMSGConversation]>(value: [])
    public var allUnreadCount: Int {
        return JMSGConversation.getAllUnreadCount().intValue
    }

    public var accountPeer: AccountPeer?
    public unowned var chatManager: IMChatManger
    public init(_ accountPeer: AccountPeer?, chatManager: IMChatManger) {
        self.accountPeer = accountPeer
        self.chatManager = chatManager
        super.init()
        loadInitConversations()
        bindMsgNotif()
    }

    public func cleanMessage(conversation: JMSGConversation? = .none) -> Bool {
        let status = conversation?.deleteAllMessages() ?? true
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kDeleteAllMessage), object: nil)
        }
        return status
    }

    public func sendMessage(message: ChatMessageReadable, to peer: Peer) {
        let message = JMSGMessage.createSingleMessage(with: message.chatMsgBody, username: peer.peerInfo.imId)
        JMSGMessage.send(message)
    }
    
    public func deleteConversation(conversation: JMSGConversation) {
        let tager = conversation.target
        JCDraft.update(text: nil, conversation: conversation)
        if conversation.ex.isGroup {
            guard let group = tager as? JMSGGroup else {
                return
            }
            JMSGConversation.deleteGroupConversation(withGroupId: group.gid)
        } else {
            guard let user = tager as? JMSGUser else {
                return
            }
            JMSGConversation.deleteSingleConversation(withUsername: user.username, appKey: user.appKey!)
        }
        reloadConversationList()
    }
}

public extension IMConversationManager {
    func reloadConversationList() {
        if try! self.chatManager.loginStatusSubject.value() == .logged {
            _getConversations()
        } else {
            self.conversationList.onNext([])
        }
    }
}

fileprivate extension IMConversationManager {
    func bindMsgNotif() {
        JMessage.add(self, with: nil)
    }
    
    func loadInitConversations() {
        if try! self.chatManager.loginStatusSubject.value() == .logged {
            _getConversations(reloadUserData: true)
        } else {
            self.conversationList.onNext([])
        }
    }
    
    func getUserInfo(old user: JMSGUser, finish: @escaping (JMSGUser) -> Void) {
        JMSGUser.userInfoArray(withUsernameArray: [user.username]) { [weak self] result, _ in
            printLog("@+++++++更新用户信息 result:\(result)")
            self?._getConversations()
        }
    }
    
    func _getConversations(reloadUserData: Bool = false) {
        JMSGConversation.allConversations { [weak self] (result, _) in
            guard let conversatios = result else {
                return
            }
            var datas = conversatios as! [JMSGConversation]
            datas = IMConversationManager.sortConverstaions(datas)
            printLog("@+++++++更新会话列表:\(datas)")
            self?.conversationList.onNext(datas)
            
            if reloadUserData {
                let userNames = datas.filter {
                    $0.conversationType == .single
                }.map {
                    return ($0.target as! JMSGUser).username
                }
                printLog("@+++++++更新用户信息:\(userNames)")
                JMSGUser.userInfoArray(withUsernameArray: userNames) { [weak self] result, _ in
                    printLog("@+++++++更新用户信息 result:\(result)")
                    self?._getConversations()
                }
            }
        }
    }

    static func sortConverstaions(_ convs: [JMSGConversation]) -> [JMSGConversation] {
        var stickyConvs: [JMSGConversation] = []
        var allConvs: [JMSGConversation] = []
        for index in 0..<convs.count {
            let conv = convs[index]
            if !conv.ex.isGroup {
                if conv.ex.isSticky {
                    stickyConvs.append(conv)
                } else {
                    allConvs.append(conv)
                }
            }
        }

        stickyConvs = stickyConvs.sorted(by: { (c1, c2) -> Bool in
            c1.ex.stickyTime > c2.ex.stickyTime
        })

        allConvs.insert(contentsOf: stickyConvs, at: 0)
        return allConvs
    }
}

extension IMConversationManager: JMessageDelegate {
    public func onReceive(_ message: JMSGMessage!, error: Error!) {
        _getConversations()
    }

    public func onConversationChanged(_ conversation: JMSGConversation!) {
        _getConversations()
    }

    public func onGroupInfoChanged(_ group: JMSGGroup!) {
        _getConversations()
    }

    public func onSyncRoamingMessageConversation(_ conversation: JMSGConversation!) {
        _getConversations()
    }

    public func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
        _getConversations()
    }

    public func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
        _getConversations()
    }
}
