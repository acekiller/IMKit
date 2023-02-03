//
//  ChatViewController.swift
//  IMKit
//
//  Created by mars on 2021/12/17.
//

import UIKit
import JMessage

public func chat(with peer: Peer, accountPeer: AccountPeer, pushController: UIViewController) {
    print("\(peer.peerInfo.imId) - \(accountPeer.peerInfo.imId)")
    let chatVC = accountPeer.chatCreator(peer)
    pushController.navigationController?.pushViewController(chatVC, animated: true)
}
