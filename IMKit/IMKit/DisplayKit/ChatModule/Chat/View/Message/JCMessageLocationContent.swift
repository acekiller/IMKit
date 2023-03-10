//
//  JCMessageLocationContent.swift
//  JChat
//
//  Created by JIGUANG on 2017/4/19.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

open class JCMessageLocationContent: NSObject, JCMessageContentType {
    public var contentType: JMSGContentType {
        return .location
    }
    public weak var delegate: JCMessageDelegate?
    open var layoutMargins: UIEdgeInsets = .zero
    open class var viewType: JCMessageContentViewType.Type {
        return JCMessageLocationContentView.self
    }

    open var address: String?
    open var lon: Double?
    open var lat: Double?

    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: 141, height: 91)
    }
}
