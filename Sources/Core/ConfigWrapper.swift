//
//  ConfigWrapper.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

@propertyWrapper
public class Config<Value: Codable> {
    public struct Source {
        var kind: SourceKind
        var getter: () -> Value
    }
    public struct OptionalSource {
        var kind: SourceKind
        var getter: () -> Value?
    }

    var overrideValue: Value?

    private var override: OptionalSource {
        let value = overrideValue
        return .init(kind: .localOverride) { value }
    }
    private let getters: [OptionalSource]
    private let `default`: Source

    public init(_ default: @escaping () -> Value) {
        self.getters = []
        self.default = .init(kind: .localDefault,
                             getter: `default`)
    }

    var valueWithSourceName: (Value, SourceKind) {
        var overrideAndGetters = getters
        overrideAndGetters.insert(override, at: 0)
        for source in overrideAndGetters {
            if let value = source.getter() {
                return (value, source.kind)
            }
        }
        return (`default`.getter(), `default`.kind)
    }

    public var wrappedValue: Value {
        valueWithSourceName.0
    }
}
