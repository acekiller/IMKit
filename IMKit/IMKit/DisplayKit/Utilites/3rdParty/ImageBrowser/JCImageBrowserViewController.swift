//
//  JCImageBrowserViewControllerswift
//  JChatSwift
//
//  Created by oshumini on 16/6/7.
//  Copyright © 2016年 HXHG. All rights reserved.
//
import UIKit
import JMessage

class JCImageBrowserViewController: UIViewController {

    var messages: [JCMessageType]?
    var conversation: JMSGConversation!
    var currentMessage: JCMessageType!
    var imageArr: [UIImage]?
    var imgCurrentIndex: Int = 0

    fileprivate lazy var CellIdentifier = "JCMessageImageCollectionViewCell"
    fileprivate var imageBrowser: UICollectionView!
    fileprivate var imageMessages: [JMSGMessage]!
    fileprivate var isMessageType = false
    lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(ThemeManager.instance.loadImage("chat_close_x_white", .default), for: .normal)
        return btn
    }()

    fileprivate var selectImage: UIImage?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black

        if let messages = messages {
            imageMessages = getImageMessages(messages)
            if imageMessages.count > 0 {
                if let index = imageMessages.index(where: { (m) -> Bool in
                    m.msgId == currentMessage.msgId
                }) {
                    imgCurrentIndex = index
                } else {
                    imgCurrentIndex = 0
                }
                isMessageType = true
            }
        }

        setupImageBrowser()
        setupCloseButton()
    }

    override func viewDidLayoutSubviews() {
        imageBrowser.scrollToItem(at: IndexPath(item: imgCurrentIndex, section: 0), at: .left, animated: false)
//        if view.safeAreaInsets.top > 10 {
//
//        }
    }
    
    @objc func closePage() {
        self.dismiss(animated: true, completion: nil)
    }

    func setupCloseButton() {
        view.addSubview(closeBtn)
        closeBtn.frame = CGRect(x: view.frame.width - 32.0 - 15.0, y: 50.0, width: 32.0, height: 32.0)
        closeBtn.addTarget(self, action: #selector(closePage), for: .touchUpInside)
    }
    
    func getImageMessages(_ messages: [JCMessageType]) -> [JMSGMessage] {
        var imageMessages: [JMSGMessage] = []
        for message in messages {
            var msg: JMSGMessage?
            if message.targetType == .chatRoom {
                msg = message.jmessage
            } else {
                msg = conversation.message(withMessageId: message.msgId)
            }
            if msg != nil {
                if msg?.contentType == .image {
                    imageMessages.append(msg!)
                }
            }
        }
        return imageMessages
    }

    func setupImageBrowser() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        imageBrowser = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        view.addSubview(imageBrowser)
        imageBrowser.frame = view.frame

        imageBrowser.backgroundColor = UIColor.clear
        imageBrowser.delegate = self
        imageBrowser.dataSource = self
        imageBrowser.minimumZoomScale = 0
        imageBrowser.isPagingEnabled = true
        imageBrowser.register(UINib(nibName: "JCMessageImageCollectionViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: CellIdentifier)
    }

    func singleTapImage(_ gestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    func doubleTapImage(_ gestureRecognizer: UITapGestureRecognizer) {
        let cell = imageBrowser.cellForItem(at: currentIndex()) as! JCMessageImageCollectionViewCell
        cell.adjustImageScale()
    }

    fileprivate func currentIndex() -> IndexPath {
        let itemIndex: Int = Int(imageBrowser.contentOffset.x / imageBrowser.frame.size.width)
        return IndexPath(item: itemIndex, section: 0)
    }

}

extension JCImageBrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isMessageType {
            return imageMessages.count
        }
        return imageArr?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath)
        if let cell = cell as? JCMessageImageCollectionViewCell {
            if isMessageType {
                cell.setMessage(imageMessages[indexPath.row])
            } else {
                if let img = imageArr?[indexPath.row] {
                    cell.setImage(image: img)
                }

            }

            cell.delegate = self
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
    }
}

extension JCImageBrowserViewController: JCImageBrowserCellDelegate {
    func singleTap() {
        dismiss(animated: true, completion: nil)
    }

    func longTap(tableviewCell cell: JCMessageImageCollectionViewCell) {
        selectImage = cell.messageImage.image
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "保存到手机")
        actionSheet.show(in: view)
        SAIInputBarLoad()
    }
}

extension JCImageBrowserViewController: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            view.becomeFirstResponder()
            if let image = selectImage {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }

    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            MBProgressHUDJChat.show(text: "保存成功", view: view)
        } else {
            MBProgressHUDJChat.show(text: "保存失败，请重试", view: view)
        }
    }

}
