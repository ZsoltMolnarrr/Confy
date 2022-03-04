//
//  ConfigDomain.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

public struct ConfigSnapshot {
    public let name: String
    public let value: String
    public let source: SourceKind
}

public protocol ConfigDomain {
    var domainName: String { get }
    var configStore: ConfigStore { get }
    func overridesChanged()
}

extension ConfigDomain {
    var snapshots: [ConfigSnapshot] {
        return properties.compactMap { (name: String, value: Any) in
            if let overrideable = value as? OverridableProperty {
                let (value, source) = overrideable.valueWithSource
                return ConfigSnapshot(name: name,
                                      value: value,
                                      source: source)
            } else {
                return nil
            }
        }
    }

    func override(propertyName: String, with jsonString: String?) throws {
        let data = jsonString?.data(using: .utf8)
        if let config = propertyValue(named: propertyName) as? OverridableProperty {
            try config.override(with: data)
            if let data = data {
                configStore.save(domain: domainName, key: propertyName, value: data)
                overridesChanged()
            }
        }
    }

    func restoreOverrides() {
        let restoredValues = configStore.load(domain: domainName)
        for (key, value) in restoredValues {
            if let config = propertyValue(named: key) as? OverridableProperty,
                let data = value as? Data {
                try? config.override(with: data)
            }
        }
    }

    func reset(propertyName: String) {
        resetProperties(names: [propertyName])
    }

    func resetAll() {
        let allPropertyNames = properties.map { key, _ in
            key
        }
        resetProperties(names: allPropertyNames)
    }

    private func resetProperties(names: [String]) {
        names.forEach { propertyName in
            if let config = propertyValue(named: propertyName) as? OverridableProperty {
                try? config.override(with: nil)
                configStore.removeValue(domain: domainName, key: propertyName)
            }
        }
        overridesChanged()
    }

    private var properties: [(name: String, value: Any)] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap { (label: String?, value: Any) in
            guard let label = label else { return nil }
            let name = String(label.dropFirst())
            return (name, value)
        }
    }

    private func propertyValue(named: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        let pair = mirror.children.first { (label: String?, _) -> Bool in
            return label == "_" + named
        }
        return pair?.value
    }

    func overridesChanged() {
        // To be overridden
    }
}

extension Config: OverridableProperty where Value: Codable {
    func override(with data: Data?) throws {
        guard let data = data else {
            overrideValue = nil
            return
        }
        let value = try JSONDecoder().decode(Value.self, from: data)
        overrideValue = value
    }

    var valueWithSource: (String, SourceKind) {
        let (value, source) = valueWithSourceName
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(value),
              let valueString = String(data: data, encoding: .utf8) else {
              return ("", source)
        }
        return (valueString, source)
    }
}

private protocol OverridableProperty {
    var valueWithSource: (String, SourceKind) { get }
    func override(with data: Data?) throws
}
