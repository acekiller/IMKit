//
//  Peer.swift
//  IMKit
//
//  Created by mars on 2021/12/20.
//

import Foundation
import RxSwift
import AccumulateBag
import JMessage

public protocol PeerInfo {
    var imId: String { get }
}

public protocol Peer {
    var id: Int64 { get }
    var peerInfo: PeerInfo { get }
    var conversation: JMSGConversation { get }
    //
    func conversationTitle(_ hasGroupNum: Bool) -> String
    func conversationTitle(_ hasGroupNum: Bool, handle: @escaping (String) -> Void)
}

public protocol AccountPeer {
    var peerInfo: PeerInfo { get }  //  账户用户的PeerInfo
    var chatCreator: (Peer) -> UIViewController { get }   //  创建会话句柄
    var accountData: Observable<(String, String)> { get }   //  会话账号登录信息
    var jPushKey: String { get }    //  极光消息推送Key
    var accumulator: Accumulator { get }    // 统计网络调用模块配置
}
