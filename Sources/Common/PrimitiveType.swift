//
//  PrimitiveType.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

func isPrimitive(value: Any) -> Bool {
    return value is Bool
        || value is String
        || value is Int
        || value is Float
        || value is Float32
        || value is Float64
        || value is Double
        || value is UInt
        || value is UInt8
        || value is UInt16
        || value is UInt32
        || value is UInt64
}
