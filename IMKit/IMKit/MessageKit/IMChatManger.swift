import Foundation
import JMessage
import RxSwift

public enum IMError: Error {
    public enum ErrorCode {
        case noError
        case noLogin
        case logFailed
        case noConversation
        case other(Int, String)

        public var errMsg: String {
            switch self {
            case .noError:
                return "无错误"
            case .noLogin:
                return "未登录账户"
            case .noConversation:
                return "未能建立会话"
            case .logFailed:
                return "登录IM失败"
            case .other(_, let msg):
                return msg
            }
        }
    }

    case error(ErrorCode)

    public var errMsg: String {
        switch self {
        case let .error(err):
            return err.errMsg
        }
    }
}

public class IMChatManger {
    public enum IMLoginStatus {
        case logged
        case unlogin
        case left
    }
    let disposeBag = DisposeBag()
    public let loginStatusSubject = BehaviorSubject<IMLoginStatus>(value: .unlogin)
    public fileprivate(set) var accountPeer: AccountPeer? {
        didSet {
            conversationManager.accountPeer = accountPeer
        }
    }
    static public let shared: IMChatManger = IMChatManger()
    public lazy var conversationManager = IMConversationManager(accountPeer, chatManager: self)
    private init() {
        bindDataEvents()
    }

    public func loginIM(with peer: AccountPeer) -> Observable<IMLoginStatus> {
        self.accountPeer = peer
        if try! loginStatusSubject.value() == .logged {
            return Observable.just(.logged)
        }
        return peer.accountData.flatMap { [weak self] (imUid, pwd) -> Observable<IMLoginStatus> in
            if let weakSelf = self {
                return weakSelf.loginIM(imUid: imUid, password: pwd)
            }
            return Observable.just(.left)
        }
    }

    public func loginIM(imUid: String, password: String) -> Observable<IMLoginStatus> {
        let disposable = SerialDisposable()
        printLog("@++++++++> loginIM - [\(imUid)]")
        return Observable.create { subscriber in
            JMSGUser.login(withUsername: imUid, password: password) { _, error in
                guard let err = error else {
                    subscriber.onNext(.logged)
                    subscriber.onCompleted()
                    return
                }
                subscriber.onError(err)
            }
            return disposable
        }.do(onNext: { [weak self] in
            self?.loginStatusSubject.onNext($0)
        })
    }

    public func loginIM() -> Observable<IMLoginStatus> {
        guard let accPeer = accountPeer else {
            let error = IMError.error(.noLogin)
            return Observable.error(error)
        }
        if try! loginStatusSubject.value() == .logged {
            return Observable.just(.logged)
        }
        return accPeer.accountData.flatMap { [weak self] (imUid, pwd) -> Observable<IMLoginStatus> in
            if let weakSelf = self {
                return weakSelf.loginIM(imUid: imUid, password: pwd)
            }
            return Observable.just(.left)
        }
    }

    public func logoutIM() {
        printLog("@++++++++> logoutIM")
        self.loginStatusSubject.onNext(.unlogin)
        self.accountPeer = nil
        JMSGUser.logout { [weak self] in
            printLog("@++++++++> logouted IM - [\($0), \($1)]")
            self?.conversationManager.reloadConversationList()
        }
    }
//        JMSGConversation.allUnsortedConversations { [weak self] list, _ in
//            guard let conversations = list as? [JMSGConversation] else {
//                return
//            }
//            for conversation in conversations {
//                if let user = conversation.target as? JMSGUser {
//                    JMSGConversation.deleteSingleConversation(withUsername: user.username)
//                    continue
//                }
//                if let group = conversation.target as? JMSGGroup {
//                    JMSGConversation.deleteGroupConversation(withGroupId: group.gid)
//                    continue
//                }
//                if let room = conversation.target as? JMSGChatRoom {
//                    JMSGConversation.deleteChatRoomConversation(withRoomId: room.roomID)
//                }
//            }
//
//        }
//    }
}

fileprivate extension IMChatManger {
    func bindDataEvents() {
        loginStatusSubject.subscribe(onNext: { [weak self] in
            printLog("@+++++++登录状态:\($0)")
            switch $0 {
            case .logged:
                printLog("@+++++++登录成功加载会话列表")
                
            default:
                break
            }
            self?.conversationManager.reloadConversationList()
        }).disposed(by: disposeBag)
    }
}
