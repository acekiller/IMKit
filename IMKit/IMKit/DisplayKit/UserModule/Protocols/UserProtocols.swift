//
//  Protocols.swift
//  JChat
//
//  Created by JIGUANG on 2017/8/11.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

public func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
    switch (lhs, rhs) {
    case (.ok, .ok):
        return true
    case (.empty, .empty):
        return true
    case (.validating, .validating):
        return true
    case (.failed, .failed):
        return true
    default:
        return false
    }
}

public enum ValidationResult: CustomStringConvertible, Equatable {
    case ok
    case empty
    case validating
    case failed(message: String)

    public var description: String {
        switch self {
        case .ok:
            return ""
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

public protocol UserValidationService {
    func validateUsername(_ username: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
}
