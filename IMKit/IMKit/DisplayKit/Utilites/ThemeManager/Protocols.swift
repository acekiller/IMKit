//
//  Protocoles.swift
//  ThemeDemo
//
//  Created by JIGUANG on 2017/8/23.
//  Copyright © 2017年 dengyonghao. All rights reserved.
//

import UIKit

public enum ThemeStyle: Int {
    case `default` = 0
    case black
    case online
    case commonImages
}

protocol ThemeProtocol {

}

extension UIView {
    @objc func updateTheme() {
        print("update view theme")
    }
}

extension UIViewController {
    @objc func updateTheme() {
        print("update view controller theme")
    }
}

extension  ThemeProtocol where Self: UIView {

    func addThemeObserver() {
        print("addViewThemeObserver")
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: NSNotification.Name(rawValue: kUpdateTheme), object: nil)
    }

    func removeThemeObserver() {
        print("removeViewThemeObserver")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kUpdateTheme), object: nil)
    }

}

extension ThemeProtocol where Self: UIViewController {

    func addThemeObserver() {
        print("addViewControllerThemeObserver")
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: NSNotification.Name(rawValue: kUpdateTheme), object: nil)
    }

    func removeThemeObserver() {
        print("removeViewControllerThemeObserver")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kUpdateTheme), object: nil)
    }

}
