//
//  JCBaseChatViewController+Data.swift
//  IMKit
//
//  Created by mars on 2021/12/22.
//

import UIKit
import YHPhotoKit

// MARK: - JCMessageDelegate
extension JCBaseChatViewController: JCMessageDelegate {
    func updateMediaMessage(_ message: JMSGMessage, data: Data?) {
        DispatchQueue.main.async {
            if let index = self.messages.index(message) {
                let msg = self.messages[index]
                switch message.contentType {
                case .file:
                    printLog("update file message")
                    if message.ex.isShortVideo {
                        let videoContent = msg.content as! JCMessageVideoContent
                        videoContent.data = data
                        videoContent.delegate = self
                        msg.content = videoContent
                    } else {
                        let fileContent = msg.content as! JCMessageFileContent
                        fileContent.data = data
                        fileContent.delegate = self
                        msg.content = fileContent
                    }
                case .video:
                    printLog("updare video message")
                    let videoContent = msg.content as! JCMessageVideoContent
                    videoContent.image = UIImage(data: data!)
                    videoContent.delegate = self
                    msg.content = videoContent
                case .image:
                    let imageContent = msg.content as! JCMessageImageContent
                    let image = UIImage(data: data!)
                    imageContent.image = image
                    msg.content = imageContent
                default: break
                }
                msg.updateSizeIfNeeded = true
                self.chatView.update(msg, at: index)
                msg.updateSizeIfNeeded = false
            }
        }
    }

    public func message(message: JCMessageType, videoData data: Data?) {
        dismissKeyboard()
        if let data = data {
            JCVideoManager.playVideo(data: data, currentViewController: self)
        }
    }

    public func message(message: JCMessageType, location address: String?, lat: Double, lon: Double) {
        dismissKeyboard()
//        let vc = JCAddMapViewController()
//        vc.isOnlyShowMap = true
//        vc.lat = lat
//        vc.lon = lon
//        navigationController?.pushViewController(vc, animated: true)
    }

    public func message(message: JCMessageType, image: UIImage?) {
        dismissKeyboard()
        let browserImageVC = JCImageBrowserViewController()
        browserImageVC.modalPresentationStyle = .fullScreen
        browserImageVC.messages = messages
        browserImageVC.conversation = peer.conversation
        browserImageVC.currentMessage = message
        present(browserImageVC, animated: true) {
//            self.toolbar.isHidden = true
        }
    }

    public func message(message: JCMessageType, fileData data: Data?, fileName: String?, fileType: String?) {
        dismissKeyboard()
        if data == nil {
            let vc = JCFileDownloadViewController()
            vc.title = fileName
            let msg =  peer.conversation.message(withMessageId: message.msgId)
            vc.fileSize = msg?.ex.fileSize
            vc.message = msg
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let fileType = fileType else {
                return
            }
            let msg =  peer.conversation.message(withMessageId: message.msgId)!
            let content = msg.content as! JMSGFileContent
            switch fileType.fileFormat() {
            case .document:
                let vc = JCDocumentViewController()
                vc.title = fileName
                vc.fileData = data
                vc.filePath = content.originMediaLocalPath
                vc.fileType = fileType
                navigationController?.pushViewController(vc, animated: true)
            case .video, .voice:
                let url = URL(fileURLWithPath: content.originMediaLocalPath ?? "")
                try! JCVideoManager.playVideo(data: Data(contentsOf: url), fileType, currentViewController: self)
            case .photo:
                let browserImageVC = JCImageBrowserViewController()
                let image = UIImage(contentsOfFile: content.originMediaLocalPath ?? "")
                browserImageVC.imageArr = [image!]
                browserImageVC.imgCurrentIndex = 0
                present(browserImageVC, animated: true) {
//                    self.toolbar.isHidden = true
                }
            default:
                let url = URL(fileURLWithPath: content.originMediaLocalPath ?? "")
                documentInteractionController.url = url
                documentInteractionController.presentOptionsMenu(from: .zero, in: self.view, animated: true)
            }
        }
    }

    public func message(message: JCMessageType, user: JMSGUser?, businessCardName: String, businessCardAppKey: String) {
//        if let user = user {
//            let vc = JCUserInfoViewController()
//            vc.user = user
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }

    public func clickTips(message: JCMessageType) {
//        currentMessage = message
        let alertController = UIAlertController(title: "重发消息", message: "是否重新发送该消息？", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            //
        }))
        alertController.addAction(UIAlertAction(title: "发送", style: .default, handler: { [weak self] _ in
            self?.retrySendMessage(message: message)
        }))
        present(alertController, animated: true, completion: nil)
    }

    func retrySendMessage(message: JCMessageType) {
        if let index = messages.index(message) {
            messages.remove(at: index)
            chatView.remove(at: index)
            let msg =  peer.conversation.message(withMessageId: message.msgId)
            message.options.state = .sending

            if let msg = msg {
                if let content = message.content as? JCMessageImageContent,
                    let imageContent = msg.content as? JMSGImageContent {
                    imageContent.uploadHandler = {  (percent: Float, _: (String?)) -> Void in
                        content.upload?(percent)
                    }
                }
            }
            messages.append(message as! JCMessage)
            chatView.append(message)
            peer.conversation.send(msg!, optionalContent: JMSGOptionalContent.ex.default)
            chatView.scrollToLast(animated: true)
        }
    }

    public func longTapAvatarView(message: JCMessageType) {
        if !isGroup || message.options.alignment == .right {
            return
        }
        toolbar.becomeFirstResponder()
        if let user = message.sender {
            toolbar.text.append("@")
            handleAt(toolbar, NSRange(location: toolbar.text.length - 1, length: 0), user, false, user.displayName().length)
        }
    }

    public func tapUnreadTips(message: JCMessageType) {
        let vc = UnreadListViewController()
        let msg =  peer.conversation.message(withMessageId: message.msgId)
        vc.message = msg
        navigationController?.pushViewController(vc, animated: true)
    }
}

// extension JCBaseChatViewController: UIAlertViewDelegate {
//    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
//        if alertView.tag == 10001 {
//            if buttonIndex == 1 {
//                JCAppManager.openAppSetter()
//            }
//            return
//        }
//    }
// }

extension JCBaseChatViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else {
            return true
        }
        if view.isKind(of: JCMessageTextContentView.self) {
            return false
        }
        return true
    }
}

extension JCBaseChatViewController: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    public func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return view
    }
    public func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
}

// MARK: - JCRecordVoiceHelperDelegate
extension JCBaseChatViewController: JCRecordVoiceHelperDelegate {
    public func beyondLimit(_ time: TimeInterval) {
        recordHelper.finishRecordingCompletion()
        recordingHub.removeFromSuperview()
        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension JCBaseChatViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage?
        if let image = image?.fixOrientation() {
            send(forImage: image)
        }
        let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as! URL?
        if videoUrl != nil {
            // let data = try! Data(contentsOf: videoUrl!)
            // send(fileData: data)

            let format = "mov" // 系统拍的是 mov 格式
            let videoData = try! Data(contentsOf: videoUrl!)
            let thumb = self.videoFirstFrame(videoUrl!, size: CGSize(width: JC_VIDEO_MSG_IMAGE_WIDTH, height: JC_VIDEO_MSG_IMAGE_HEIGHT))
            let thumbData = thumb.pngData()
            let avUrl = AVURLAsset(url: videoUrl!)
            let time = avUrl.duration
            let seconds = ceil(Double(time.value)/Double(time.timescale))
            self.send(videoData: videoData, thumbData: thumbData!, duration: seconds, format: format)

            /* 可选择转为 MP4 再发
            conversionVideoFormat(videoUrl!) { (paraUrl) in
                if paraUrl != nil {
                    //send  video message
                }
            }*/
        }
    }
    // 视频转 MP4 格式
    func conversionVideoFormat(_ inputUrl: URL, callback: @escaping (_ para: URL?) -> Void) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let strDate = formatter.string(from: date) as String

        let path = "\(NSHomeDirectory())/Documents/output-\(strDate).mp4"
        let outputUrl: URL = URL(fileURLWithPath: path)

        let avAsset = AVURLAsset(url: inputUrl)
        let exportSeesion = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
        exportSeesion?.outputURL = outputUrl
        exportSeesion?.outputFileType = AVFileType.mp4
        exportSeesion?.exportAsynchronously(completionHandler: {
            switch exportSeesion?.status {
            case AVAssetExportSession.Status.unknown?:
                break
            case AVAssetExportSession.Status.cancelled?:
                callback(nil)
                break
            case AVAssetExportSession.Status.waiting?:
                break
            case AVAssetExportSession.Status.exporting?:
                break
            case AVAssetExportSession.Status.completed?:
                callback(outputUrl)
                break
            case AVAssetExportSession.Status.failed?:
                callback(nil)
                break
            default:
                callback(nil)
                break
            }
        })
    }
    // 获取视频第一帧
    func videoFirstFrame(_ videoUrl: URL, size: CGSize) -> UIImage {
        let opts = [AVURLAssetPreferPreciseDurationAndTimingKey: false]
        let urlAsset = AVURLAsset(url: videoUrl, options: opts)
        let generator = AVAssetImageGenerator(asset: urlAsset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: size.width, height: size.height)
        // let error: Error
        do {
            let img = try generator.copyCGImage(at: CMTimeMake(value: 0, timescale: 10), actualTime: nil) as CGImage
            let image = UIImage(cgImage: img)
            return image
        } catch let error as NSError {
            print("\(error)")
            return UIImage.createImage(color: .gray, size: CGSize(width: JC_VIDEO_MSG_IMAGE_WIDTH, height: JC_VIDEO_MSG_IMAGE_HEIGHT))!
        }
    }
    
    func dismissKeyboard() {
        inputItem = nil
        toolbar.resignFirstResponder()
    }
}
