//
//  ChatMessageReadable.swift
//  IMKit
//
//  Created by mars on 2021/12/28.
//

import Foundation
public protocol ChatMessageReadable {
    var chatMsgBody: JMSGCustomContent { get }
}
