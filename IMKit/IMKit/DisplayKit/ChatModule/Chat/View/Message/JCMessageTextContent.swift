//
//  JCMessageTextContent.swift
//  JChat
//
//  Created by JIGUANG on 2017/3/9.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

open class JCMessageTextContent: NSObject, JCMessageContentType {
    public var contentType: JMSGContentType {
        return .text
    }
    public weak var delegate: JCMessageDelegate?
    public override init() {
        let text = "this is a test text"
        self.text = NSAttributedString(string: text)
        super.init()
    }
    public init(text: String) {
        self.text = NSAttributedString(string: text)
        super.init()
    }
    public init(attributedText: NSAttributedString) {
        self.text = attributedText
        super.init()
    }

    open class var viewType: JCMessageContentViewType.Type {
        return JCMessageTextContentView.self
    }
    open var layoutMargins: UIEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)

    open var text: NSAttributedString

    open func sizeThatFits(_ size: CGSize) -> CGSize {
        let mattr = NSMutableAttributedString(attributedString: text)
        mattr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "PingFangSC-Regular", size: 14.0), range: NSRange(location: 0, length: mattr.length))
        self.text = mattr
        let label = KILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.attributedText = mattr
        let mattrSize = label.sizeThatFits(size)
        return .init(width: ceil(mattrSize.width), height: ceil(mattrSize.height))
    }
}
