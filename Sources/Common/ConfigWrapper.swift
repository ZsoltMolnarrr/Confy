//
//  ConfigWrapper.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

@propertyWrapper
public class Config<Value: Codable> {
    struct Source {
        var kind: ConfigSourceKind
        var getter: () -> Value
    }
    struct OptionalSource {
        var kind: ConfigSourceKind
        var getter: () -> Value?
    }

    var overrideValue: Value?
    private var override: OptionalSource {
        let value = overrideValue
        return .init(kind: .localOverride) { value }
    }
    private let getters: [OptionalSource]
    private let `default`: Source

    public convenience init(sourceName: String, getter: @escaping () -> Value?, default: @escaping () -> Value) {
        self.init(sources: [(sourceName, getter)], default: `default`)
    }

    public init(sources: [(String, () -> Value?)], default: @escaping () -> Value) {
        self.getters = sources.map {
            OptionalSource(kind: .custom($0), getter: $1)
        }
        self.default = Source(kind: .localDefault, getter: `default`)
    }

    public init(_ default: @escaping () -> Value) {
        self.getters = []
        self.default = .init(kind: .localDefault,
                             getter: `default`)
    }

    var valueWithSourceName: (Value, ConfigSourceKind) {
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
    
    public var projectedValue: Config<Value> {
        self
    }
    
    public func override(value: Value) {
        overrideValue = value
    }
}
