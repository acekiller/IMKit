//
//  WKGroupMemberCell.swift
//  CCZAPPiOS
//
//  Created by 国信利安-1 on 2019/8/23.
//  Copyright © 2019 ccz. All rights reserved.
//

import UIKit
import JMessage

class WKGroupMemberCell: UICollectionViewCell {

    var avator: UIImage? {
        get {
            return avatorView.image
        }
        set {
            nickname.text = ""
            avatorView.image = newValue
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }

    private var avatorView: UIImageView = UIImageView()
    private var nickname: UILabel = UILabel()
    //    private lazy var userDefaultIcon = UIImage.loadImage("com_icon_user_50")
    private lazy var userDefaultIcon = UIImage.init(named: "icon_user_defaultavatar_boy")

    private func _init() {

        nickname.font = UIFont.systemFont(ofSize: 12)
        nickname.textAlignment = .left

        addSubview(avatorView)
        addSubview(nickname)
//
        addConstraint(_JCLayoutConstraintMake(avatorView, .centerY, .equal, contentView, .centerY))
        addConstraint(_JCLayoutConstraintMake(avatorView, .width, .equal, nil, .notAnAttribute, 50))
        addConstraint(_JCLayoutConstraintMake(avatorView, .height, .equal, nil, .notAnAttribute, 50))
        addConstraint(_JCLayoutConstraintMake(avatorView, .left, .equal, contentView, .left, 10))

        addConstraint(_JCLayoutConstraintMake(nickname, .centerY, .equal, contentView, .centerY))
        addConstraint(_JCLayoutConstraintMake(nickname, .height, .equal, nil, .notAnAttribute, 15))
        addConstraint(_JCLayoutConstraintMake(nickname, .left, .equal, avatorView, .right, 5))
        addConstraint(_JCLayoutConstraintMake(nickname, .right, .equal, contentView, .right, -10))
    }

    func bindDate(user: JMSGUser) {
        nickname.text = user.displayName()
        user.thumbAvatarData { (data, _, _) in
            if let data = data {
                let image = UIImage(data: data)
                self.avatorView.image = image
            } else {
                self.avatorView.image = self.userDefaultIcon
            }
        }
    }

}
