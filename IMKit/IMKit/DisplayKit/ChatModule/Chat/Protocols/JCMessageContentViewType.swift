//
//  JCMessageContentViewType.swift
//  JChat
//
//  Created by JIGUANG on 10/04/2017.
//  Copyright © 2017 HXHG. All rights reserved.
//

import UIKit

@objc public protocol JCMessageContentType: class {
    var contentType: JMSGContentType { get }
    weak var delegate: JCMessageDelegate? { get }
    var layoutMargins: UIEdgeInsets { get }

    func sizeThatFits(_ size: CGSize) -> CGSize

    static var viewType: JCMessageContentViewType.Type { get }
}

@objc public protocol JCMessageContentViewType: class {

    init()
    func apply(_ message: JCMessageType)
}
