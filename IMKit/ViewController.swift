//
//  ViewController.swift
//  IMKit
//
//  Created by mars on 2021/12/17.
//

import UIKit
import RxSwift
import AccumulateBag

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button = UIButton(type: .custom)
        button.setTitle("Chat", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: view.frame.size.width / 2.0 - 40.0, y: view.frame.size.height / 2.0 - 20.0, width: 80.0, height: 40.0)
        view.addSubview(button)
        button.addTarget(self, action: #selector(toChat), for: .touchUpInside)

        _ = IMChatManger.shared.loginIM(with: getAccountPeer()).subscribe(onNext: {
           print("login status @+++++ \($0)")
        }, onError: {
            print("login failed @+++++ \($0)")
        })
    }

    @objc func toChat() {
        guard let accountPeer = IMChatManger.shared.accountPeer else {
            return
        }

        let chatPeerId = "b@39@1455016305990774784"
        JMSGConversation.createSingleConversation(withUsername: chatPeerId, appKey: JPushKey) { [weak self] resoult, _ in
            guard let conversation = resoult as? JMSGConversation else {
                return
            }
            let chatPeer = UserPeer(id: 0, imId: chatPeerId, conversation: conversation)
            self?.toChatWith(peer: chatPeer, accountPeer: accountPeer)
        }
    }

    func toChatWith(peer: Peer, accountPeer: AccountPeer) {
        chat(with: peer, accountPeer: accountPeer, pushController: self)
    }
}
