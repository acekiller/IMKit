//
//  AppDelegate.swift
//  IMKit
//
//  Created by mars on 2021/12/17.
//

import UIKit
import RxSwift
import AccumulateBag
import JMessage

let JPushKey = "735551610f5b36685dd9d877"

struct UserPeerInfo: PeerInfo {
    var imId: String
}

struct UserPeer: Peer {
    var id: Int64
    var peerInfo: PeerInfo
    var conversation: JMSGConversation
    func conversationTitle(_ hasGroupNum: Bool) -> String {
        return conversation.title ?? ""
    }

    init(id: Int64, imId: String, conversation: JMSGConversation) {
        self.id = id
        self.peerInfo = UserPeerInfo(imId: imId)
        self.conversation = conversation
    }
}

class AccountPeerImpl: AccountPeer {
    var peerInfo: PeerInfo
    let imId: String
    var jPushKey: String
    var accumulator: Accumulator
    var chatCreator: (Peer) -> UIViewController

    init(imId: String, jPushKey: String, accumulator: Accumulator, chat creator: @escaping (Peer) -> UIViewController) {
        self.imId = imId
        self.accumulator = accumulator
        self.jPushKey = jPushKey
        self.chatCreator = creator
        self.peerInfo = UserPeerInfo(imId: imId)
    }

    var accountData: Observable<(String, String)> {
        let password = encodBase64(text: imId)
        return Observable.just((imId, password))
    }

    func encodBase64(text: String) -> String {
        if let data = text.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
    }
}

func getAccountPeer() -> AccountPeerImpl {
    let accountId = "c@100@1455462372087500800"
    return AccountPeerImpl(imId: accountId, jPushKey: JPushKey, accumulator: Accumulator.accumulator()) { peer in
        return JCChatViewController(peer: peer)
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, JMessageDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerJmessage(launchOptions: launchOptions)
        return true
    }

    func registerJmessage(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let production = false // 开发环境 NO 生产环境为 YES
        JMessage.setupJMessage(launchOptions, appKey: JPushKey, channel: "iOS", apsForProduction: production, category: nil, messageRoaming: true)
        JMessage.add(self, with: nil)
//        JMessage.setLogOFF()
        JMessage.register(
            forRemoteNotificationTypes: UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.sound.rawValue | UNAuthorizationOptions.alert.rawValue,
            categories: nil)
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
