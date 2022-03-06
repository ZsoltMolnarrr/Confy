//
//  ConfigSourceKind.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

enum ConfigSourceKind {
    case localDefault
    case custom(String)
    case localOverride
}

extension ConfigSourceKind {
    var name: String {
        switch self {
        case .localDefault:
            return "Local default"
        case .custom(let name):
            return name
        case .localOverride:
            return "Local override"
        }
    }
}

extension ConfigSourceKind: Equatable {}
