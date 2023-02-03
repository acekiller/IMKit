//
//  UIViewController+JChat.swift
//  JChat
//
//  Created by JIGUANG on 2017/10/8.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

public extension UIViewController {
    @objc open func back(_ animated: Bool = true) {
        navigationController?.popViewController(animated: true)
    }
}
