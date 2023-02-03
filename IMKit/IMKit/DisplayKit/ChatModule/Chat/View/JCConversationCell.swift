//
//  JCConversationCell.swift
//  JChat
//
//  Created by JIGUANG on 2017/3/22.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import SnapKit
import JMessage

extension UIView {
    static func roundCorners(with view: UIView, cornerRadius: Double) {
        if #available(iOS 11.0, *) {
            let corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            view.layer.cornerRadius = CGFloat(cornerRadius)
            view.clipsToBounds = true
            view.layer.masksToBounds = true
            view.layer.maskedCorners = corners
        } else {
            let corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
           let maskLayer = CAShapeLayer()
           maskLayer.frame = view.bounds
           maskLayer.path = path.cgPath
            view.layer.mask = maskLayer
        }
     }
}

class JCConversationCell: JCTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        _init()
    }
    private lazy var bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        UIView.roundCorners(with: v, cornerRadius: 2.0)
        return v
    }()

    private lazy var avatorView: UIImageView = {
        let avatorView = UIImageView()
        avatorView.contentMode = .scaleToFill
        UIView.roundCorners(with: avatorView, cornerRadius: 4)
        return avatorView
    }()

    private lazy var statueView: UIImageView = UIImageView()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor(netHex: 0x333333)
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return titleLabel
    }()
    private lazy var msgLabel: UILabel = {
        let msgLabel = UILabel()
        msgLabel.textColor = UIColor(netHex: 0x808080)
        msgLabel.font = UIFont.systemFont(ofSize: 14)
        return msgLabel
    }()
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textAlignment = .right
        dateLabel.font = UIFont.systemFont(ofSize: 11)
        dateLabel.textColor = UIColor(netHex: 0x999999)
        return dateLabel
    }()
    private lazy var redPoin: UILabel = {
        let redPoin = UILabel(frame: CGRect(x: 65 - 17, y: 4.5, width: 16, height: 16))
        redPoin.textAlignment = .center
        redPoin.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        redPoin.textColor = .white
        redPoin.layer.backgroundColor = UIColor(netHex: 0xFF3B30).cgColor
        redPoin.textAlignment = .center
        return redPoin
    }()

    // MARK: - public func
    open func bindConversation(_ conversation: JMSGConversation) {
        statueView.isHidden = true
        let isGroup = conversation.ex.isGroup
        if conversation.unreadCount != nil && (conversation.unreadCount?.intValue)! > 0 {
            redPoin.isHidden = false
            var text = ""
            if (conversation.unreadCount?.intValue)! > 99 {
                text = "99+"
                redPoin.layer.cornerRadius = 9.0
                redPoin.layer.masksToBounds = true
                redPoin.frame = CGRect(x: 65 - 28, y: 4.5, width: 33, height: 18)
            } else {
                redPoin.layer.cornerRadius = 10.0
                redPoin.layer.masksToBounds = true
                redPoin.frame = CGRect(x: 65 - 15, y: 4.5, width: 20, height: 20)
                text = "\(conversation.unreadCount!)"
            }
            redPoin.text = text

            var isNoDisturb = false
            if isGroup {
                if let group = conversation.target as? JMSGGroup {
                    isNoDisturb = group.isNoDisturb
                }
            } else {
                if let user = conversation.target as? JMSGUser {
                    isNoDisturb = user.isNoDisturb
                }
            }

            if isNoDisturb {
                redPoin.layer.cornerRadius = 4.0
                redPoin.layer.masksToBounds = true
                redPoin.text = ""
                redPoin.frame = CGRect(x: 65 - 5, y: 4.5, width: 8, height: 8)
            }
        } else {
            redPoin.isHidden = true
        }

        if let latestMessage = conversation.latestMessage {
            let time = latestMessage.timestamp.intValue / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            dateLabel.text = date.conversationDate()
        } else {
            dateLabel.text = ""
        }

        msgLabel.text = conversation.latestMessageContentText()
        if isGroup {
            if let latestMessage = conversation.latestMessage {
                let fromUser = latestMessage.fromUser
                if !fromUser.isEqual(to: JMSGUser.myInfo()) &&
                    latestMessage.contentType != .eventNotification &&
                    latestMessage.contentType != .prompt {
                    msgLabel.text = "\(fromUser.displayName()):\(msgLabel.text!)"
                }
                if conversation.unreadCount != nil &&
                    conversation.unreadCount!.intValue > 0 &&
                    latestMessage.contentType != .prompt {
                    if latestMessage.isAtAll() {
                        msgLabel.attributedText = getAttributString(attributString: "[@所有人]", string: msgLabel.text!)
                    } else if latestMessage.isAtMe() {
                        msgLabel.attributedText = getAttributString(attributString: "[有人@我]", string: msgLabel.text!)
                    }
                }
            }
        }

        if let draft = JCDraft.getDraft(conversation) {
            if !draft.isEmpty {
                msgLabel.attributedText = getAttributString(attributString: "[草稿]", string: draft)
            }
        }

        if !isGroup {
            let user = conversation.target as? JMSGUser
            let displayName = user?.displayName() ?? ""
//            let account = user?.username ?? ""
//            let index = account.index(account.startIndex, offsetBy: 3)
//            let sub2 = account[..<index]
//
//            let index2 = account.index(account.endIndex, offsetBy: -4)
//            //改成这样才多哦
//            let sub4 = account[index2..<account.endIndex]
//            titleLabel.text = displayName + "(" + sub2 + "****" + sub4 + ")"
            titleLabel.text = displayName
            user?.thumbAvatarData { (data, _, _) in
                guard let imageData = data else {
                    let image = UIImage.init(named: "message_default")
                    self.avatorView.image = image
//                    self.avatorView.image = self.userDefaultIcon
                    return
                }
                self.avatorView.image = UIImage(data: imageData)
            }
        } else {
            if let group = conversation.target as? JMSGGroup {
                titleLabel.text = group.displayName()
                if group.isShieldMessage {
                    statueView.isHidden = false
                }
                group.thumbAvatarData({ (data, _, _) in
                    if let data = data {
                        self.avatorView.image = UIImage(data: data)
                    } else {
                        self.avatorView.image = self.groupDefaultIcon
                    }
                })
            }
        }

        if conversation.ex.isSticky {
            backgroundColor = UIColor(netHex: 0xF5F6F8)
        } else {
            backgroundColor = .white
        }
    }

    func getAttributString(attributString: String, string: String) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString(string: "")
        var attrSearchString: NSAttributedString!
        attrSearchString = NSAttributedString(string: attributString, attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor(netHex: 0xEB424C), convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.boldSystemFont(ofSize: 14.0)]))
        attr.append(attrSearchString)
        attr.append(NSAttributedString(string: string))
        return attr
    }

    private lazy var groupDefaultIcon = UIImage.loadImage("com_icon_group_50")
    private lazy var userDefaultIcon = UIImage.loadImage("com_icon_user_50")

    // MARK: - private func
    private func _init() {
        self.selectionStyle = .none
        avatorView.image = userDefaultIcon
        statueView.image = UIImage.loadImage("com_icon_shield")

        contentView.backgroundColor = UIColor(netHex: 0xF5F7FC)
        contentView.addSubview(bgView)
        bgView.addSubview(avatorView)
        bgView.addSubview(statueView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(msgLabel)
        bgView.addSubview(dateLabel)
        bgView.addSubview(redPoin)

        bgView.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.bottom.equalTo(-4)
            make.left.equalTo(11)
            make.right.equalTo(-13)
        }
        avatorView.snp.makeConstraints { make in
            make.left.equalTo(7)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalTo(-20)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatorView.snp.top)
            make.left.equalTo(avatorView.snp.right).offset(12)
            make.right.equalTo(dateLabel.snp.left).offset(-10)
        }
        msgLabel.snp.makeConstraints { make in
            make.bottom.equalTo(avatorView.snp.bottom).offset(-4)
            make.left.equalTo(avatorView.snp.right).offset(12)
            make.trailing.lessThanOrEqualTo(100)
        }

//        addConstraint(_JCLayoutConstraintMake(avatorView, .left, .equal, contentView, .left, 15))
//        addConstraint(_JCLayoutConstraintMake(avatorView, .top, .equal, contentView, .top, 7.5))
//        addConstraint(_JCLayoutConstraintMake(avatorView, .width, .equal, nil, .notAnAttribute, 50))
//        addConstraint(_JCLayoutConstraintMake(avatorView, .height, .equal, nil, .notAnAttribute, 50))
//
//        addConstraint(_JCLayoutConstraintMake(titleLabel, .left, .equal, avatorView, .right, 10.5))
//        addConstraint(_JCLayoutConstraintMake(titleLabel, .top, .equal, contentView, .top, 10.5))
//        addConstraint(_JCLayoutConstraintMake(titleLabel, .right, .equal, dateLabel, .left, 50))
//        addConstraint(_JCLayoutConstraintMake(titleLabel, .height, .equal, nil, .notAnAttribute, 22.5))
//
//        addConstraint(_JCLayoutConstraintMake(msgLabel, .left, .equal, titleLabel, .left))
//        addConstraint(_JCLayoutConstraintMake(msgLabel, .top, .equal, titleLabel, .bottom, 1.5))
//        addConstraint(_JCLayoutConstraintMake(msgLabel, .right, .equal, statueView, .left, -5))
//        addConstraint(_JCLayoutConstraintMake(msgLabel, .height, .equal, nil, .notAnAttribute, 20))
//
//        addConstraint(_JCLayoutConstraintMake(dateLabel, .top, .equal, contentView, .top, 16))
//        addConstraint(_JCLayoutConstraintMake(dateLabel, .right, .equal, contentView, .right, -15))
//        addConstraint(_JCLayoutConstraintMake(dateLabel, .height, .equal, nil, .notAnAttribute, 16.5))
//        addConstraint(_JCLayoutConstraintMake(dateLabel, .width, .equal, nil, .notAnAttribute, 100))
//
        addConstraint(_JCLayoutConstraintMake(statueView, .top, .equal, dateLabel, .bottom, 7))
        addConstraint(_JCLayoutConstraintMake(statueView, .right, .equal, contentView, .right, -16))
        addConstraint(_JCLayoutConstraintMake(statueView, .height, .equal, nil, .notAnAttribute, 12))
        addConstraint(_JCLayoutConstraintMake(statueView, .width, .equal, nil, .notAnAttribute, 12))
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
