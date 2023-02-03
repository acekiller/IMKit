//
//  JCDraft.swift
//  JChat
//
//  Created by JIGUANG on 2017/6/2.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage

public class JCDraft: NSObject {

    public static var draftCache: [String: String] = Dictionary()

    public static func update(text: String?, conversation: JMSGConversation) {
        //禁止草稿
//        let id = JCDraft.getDraftId(conversation)
//        if text == nil || (text?.isEmpty)! {
//            UserDefaults.standard.removeObject(forKey: id)
//            draftCache.removeValue(forKey: id)
//            return
//        }
//        UserDefaults.standard.set(text!, forKey: id)
//        draftCache[id] = text!
    }

    public static func getDraft(_ conversation: JMSGConversation) -> String? {
        let id = JCDraft.getDraftId(conversation)
        if let cache = draftCache[id] {
            return cache
        }
        let draft = UserDefaults.standard.object(forKey: id) as? String
        if draft != nil {
            draftCache[id] = draft
        } else {
            draftCache[id] = ""
        }
        return draft
    }

    public static func getDraftId(_ conversation: JMSGConversation) -> String {
        var id = ""
        let me = JMSGUser.myInfo()
        if me.username.isEmpty {
            return ""
        }
        if conversation.ex.isGroup {
            guard let group = conversation.target as? JMSGGroup else {
                return ""
            }
            id = "\(me.username)\(me.appKey!)\(group.gid)"
        } else {
            guard let user = conversation.target as? JMSGUser else {
                return ""
            }
            guard let appkey = user.appKey else {
                return ""
            }
            id = "\(me.username)\(me.appKey!)\(user.username)\(appkey)"
        }
        return id
    }
}
