//
//  PhotoChoiceHandler.swift
//  IMKit
//
//  Created by mars on 2021/12/30.
//

import Foundation
import YHPhotoKit

class PhotoChoiceHandler: NSObject {
    static let `default`: PhotoChoiceHandler = PhotoChoiceHandler()
    fileprivate var handle: (([Any]) -> Void)?
    func photo(target: UIViewController, maxCount: Int32 = 9, handle:@escaping ([Any]) -> Void) {
        self.handle = handle
        let vc = YHPhotoPickerViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.maxPhotosCount = maxCount
        vc.pickerDelegate = self
        target.present(vc, animated: true, completion: .none)
    }
}

// MARK: - YHPhotoPickerViewControllerDelegate
extension PhotoChoiceHandler: YHPhotoPickerViewControllerDelegate {
   public func selectedPhotoBeyondLimit(_ count: Int32, currentView view: UIView!) {
       MBProgressHUDJChat.show(text: "最多选择\(count)张图片", view: nil)
   }

    public func yhPhotoPickerViewController(_ PhotoPickerViewController: YHSelectPhotoViewController!, selectedPhotos photos: [Any]!) {
        self.handle?(photos)
   }
}
