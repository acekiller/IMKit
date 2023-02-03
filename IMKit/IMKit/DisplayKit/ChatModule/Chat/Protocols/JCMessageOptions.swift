//
//  JCMessageOptions.swift
//  JChat
//
//  Created by JIGUANG on 2017/3/8.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage

/// 消息类型
@objc public enum JCMessageStyle: Int {
    case notice
    case bubble
    case custom
}

/// 消息对齐方式
@objc public enum JCMessageAlignment: Int {
    case left
    case right
    case center
}

@objc public enum JCMessageState: Int {
    case sending
    case sendError
    case sendSucceed
    case downloadFailed
}

/// 消息选项
@objc open class JCMessageOptions: NSObject {

    public override init() {
        super.init()
    }

    public convenience init(with content: JCMessageContentType) {
        self.init()

        switch content {
        case is JCMessageNoticeContent:
            self.style = .notice
            self.alignment = .center
            self.showsCard = false
            self.showsAvatar = false
            self.showsBubble = true
            self.isUserInteractionEnabled = false

        case is JCMessageTimeLineContent:
            self.style = .notice
            self.alignment = .center
            self.showsCard = false
            self.showsAvatar = false
            self.showsBubble = false
            self.isUserInteractionEnabled = false

//        case is JCMessageImageContent:
//            self.showsTips = false

        default:
            break
        }
    }

    open var contentInset: UIEdgeInsets = .zero
    open var bubbleInset: UIEdgeInsets = .zero
    open var style: JCMessageStyle = .bubble
    open var alignment: JCMessageAlignment = .left

    open var isUserInteractionEnabled: Bool = true

    open var showsCard: Bool = false
    open var showsAvatar: Bool =  true
    open var showsBubble: Bool = true
    open var showsTips: Bool = true
    open var state: JCMessageState = .sendSucceed
    
    open lazy var send_nor =  ThemeManager.instance.send_nor
    open lazy var send_press = ThemeManager.instance.send_press

    open lazy var recive_nor = ThemeManager.instance.recive_nor
    open lazy var recive_press = ThemeManager.instance.recive_press
    
    open var normalImage: UIImage? {
        switch alignment {
        case .left:
            return recive_nor

        case .right:
            return send_nor

        case .center:
            return .none
        }
    }
    
    open var pressImage: UIImage? {
        switch alignment {
        case .left:
            return recive_press

        case .right:
            return send_press

        case .center:
            return .none
        }
    }
    

    internal func fix(with content: JCMessageContentType) {
    }
}
