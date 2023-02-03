//
//  IMBaseViewController.swift
//  IMKit
//
//  Created by mars on 2021/12/21.
//

import UIKit
import RxSwift
import AccumulateBag

open class IMBaseViewController: UIViewController {
    open var disposeBag = DisposeBag()

    //    页面默认埋点标记
    var trackLabel: String { "\(Unmanaged<AnyObject>.passUnretained(self).toOpaque())" }
    var trackCode: String { "\(self.classForCoder)" }
    var loadTrack: Bool { true }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    var disposeBag = DisposeBag()

//    var titleLabel = UILabel()
//
//    open override var title: String? {
//        didSet {
//            guard let titleStr = self.title else {
//                return
//            }
//            //            self.navigationItem.title = titleStr
//            if titleStr.count > 10 {
//                self.titleLabel.text = "\(String(describing: titleStr.getSubString(startIndex: 0, endIndex: 9)))..."
//            } else {
//                self.titleLabel.text = titleStr
//            }
//        }
//    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        if loadTrack {
            let activityCode = trackCode
            var params = trackPageParams
            params["activity"] = activityCode

            IMChatManger.shared.accountPeer?.accumulator.start(label: trackLabel,
                                            time: convertToString(date: absoluteNow()),
                                            key: activityCode,
                                            value: params)
        }
    }

    deinit {
        if loadTrack {
            let activityCode = trackCode
            var params = trackPageParams
            params["activity"] = activityCode
            IMChatManger.shared.accountPeer?.accumulator.end(label: trackLabel,
                                          time: convertToString(date: absoluteNow()),
                                          key: activityCode,
                                          value: params)
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    open override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        let back = UIBarButtonItem.init(image: ThemeManager.instance.loadImage("chat_common_back_icon", .default)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        return back
    }

#if DEBUG // 摇一摇
open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        print("摇一摇")
        //        FLEXManager.shared.showExplorer()
    }
#endif

    /// 隐藏导航栏
    func hiddenNavigationBar(_ hidden: Bool) {
        self.navigationController?.navigationBar.isHidden = hidden
        self.navigationController?.setNavigationBarHidden(hidden, animated: false)
    }

    /// 设置导航栏颜色
//    func setNavigationBarColor(color: UIColor) {
//        // Fix Nav Bar tint issue in iOS 15.0 or later - is transparent w/o code below
//        if #available(iOS 15, *) {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
//            appearance.backgroundColor = color
//            appearance.backgroundEffect = nil
//            appearance.shadowColor = nil
//            self.navigationController?.navigationBar.standardAppearance = appearance
//            self.navigationController?.navigationBar.scrollEdgeAppearance = nil
//        } else {
//            // 导航栏透明效果
//            let colorImg = UIImage.qmui_image(with: color, size: CGSize(width: UIScreen.main.bounds.width, height: 88), cornerRadius: 0)
//            self.navigationController?.navigationBar.setBackgroundImage(colorImg, for: .default)
//            // 去掉下面的那条线
//            self.navigationController?.navigationBar.shadowImage = UIImage()
//        }
//    }

    /// 设置导航栏为透明
    func setNavigationBarClear() {
        // Fix Nav Bar tint issue in iOS 15.0 or later - is transparent w/o code below
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
            appearance.backgroundColor = .clear
            appearance.backgroundEffect = nil
            appearance.shadowColor = nil
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = nil
        } else {
            // 导航栏透明效果
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            // 去掉下面的那条线
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }

//    // 获取当前显示的ViewController
//    func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//        if let nav = base as? UINavigationController {
//            return currentViewController(base: nav.visibleViewController)
//        }
//        if let tab = base as? UITabBarController {
//            return currentViewController(base: tab.selectedViewController)
//        }
//        if let presented = base?.presentedViewController {
//            return currentViewController(base: presented)
//        }
//        return base
//    }
}

extension IMBaseViewController {
    var trackPageParams: [String: Any] {
        var value = [String: Any]()
        value["type"] = 1
        return value
    }

    func absoluteNow(_ future: TimeInterval = 0.0) -> Date {
        return Date(timeIntervalSince1970: nowTimeInterval + future)
    }

    var nowTimeInterval: TimeInterval {
        return CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970
    }

    func convertToString(date: Date, dateFormat: String="yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}
