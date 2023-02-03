//
//  JCMessageAvatarView.swift
//  JChat
//
//  Created by JIGUANG on 10/04/2017.
//  Copyright © 2017 HXHG. All rights reserved.
//

import UIKit

open class JCMessageAvatarView: UIImageView, JCMessageContentViewType {

    weak var delegate: JCMessageDelegate?

    public override init(image: UIImage?) {
        super.init(image: image)
        self.frame = CGRect(origin: .zero, size: CGSize(width: 40.0, height: 40.0))
        _commonInit()
    }
    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        _commonInit()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }

    open func apply(_ message: JCMessageType) {
        self.message = message
        if message.senderAvator != nil {
            image = message.senderAvator
            return
        }
        weak var weakSelf = self
        message.sender?.thumbAvatarData({ (data, _, _) in
            if let data = data {
                weakSelf?.image = UIImage(data: data)
            } else {
                self.image = self.userDefaultIcon
            }
        })
    }

    private var message: JCMessageType!
    private lazy var userDefaultIcon = UIImage.init(named: "message_default")

    private func _commonInit() {
        image = userDefaultIcon
        isUserInteractionEnabled = true
        layer.masksToBounds = true
        layer.cornerRadius = 36.0 / 2.0

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(_tapHandler))
        self.addGestureRecognizer(tapGR)

        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(_longTap(_:)))
        longTapGesture.minimumPressDuration = 0.4
        addGestureRecognizer(longTapGesture)
    }

    @objc func _tapHandler(sender: UITapGestureRecognizer) {
        delegate?.tapAvatarView?(message: message)
    }

    @objc func _longTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            delegate?.longTapAvatarView?(message: message)
        }
    }
    
    open override var frame: CGRect {
        didSet {
            layer.cornerRadius = frame.size.height / 2.0
        }
    }

}
