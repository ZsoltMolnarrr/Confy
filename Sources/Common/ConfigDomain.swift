//
//  ConfigDomain.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

public protocol ConfigDomain: AnyObject {
    var configDomainName: String { get }
    var configStore: PersistentConfigStore? { get }
    func overridesChanged()
}

public extension ConfigDomain {
    var configStore: PersistentConfigStore? {
        Confy.defaultPersistentStore
    }

    var configDomainName: String {
        String(describing: self)
    }

    func overridesChanged() {
        // To be overridden
    }

    func restoreOverrides() {
        guard let configStore = configStore else { return }
        let restoredValues = configStore.load(domain: configDomainName)
        for (key, value) in restoredValues {
            if let config = propertyValue(named: key) as? OverridableProperty,
                let data = value as? Data {
                try? config.override(with: data)
            }
        }
    }
}

extension ConfigDomain {
    var snapshots: [ConfigSnapshot] {
        return properties.compactMap { (name: String, value: Any) in
            if let overrideable = value as? OverridableProperty {
                return overrideable.makeSnapshot(for: name)
            } else {
                return nil
            }
        }
    }

    func override(propertyName: String, with jsonString: String?) throws {
        let data = jsonString?.data(using: .utf8)
        if let config = propertyValue(named: propertyName) as? OverridableProperty {
            try config.override(with: data)
            if let configStore = configStore, let data = data {
                configStore.save(domain: configDomainName, key: propertyName, value: data)
                overridesChanged()
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
                if let configStore = configStore {
                    configStore.removeValue(domain: configDomainName, key: propertyName)
                }
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
}

struct ConfigSnapshot {
    let name: String
    let source: ConfigSourceKind
    let encodedValue: String
    let value: Any
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

    func makeSnapshot(for name: String) -> ConfigSnapshot {
        let (value, source) = valueWithSourceName
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodedValue: String
        if let data = try? encoder.encode(value),
           let valueString = String(data: data, encoding: .utf8) {
              encodedValue = valueString
        } else {
            encodedValue = ""
        }
        return .init(name: name,
                     source: source,
                     encodedValue: encodedValue,
                     value: value)
    }

    var valueWithSource: (String, ConfigSourceKind) {
        let (value, source) = valueWithSourceName
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(value),
              let valueString = String(data: data, encoding: .utf8) else {
              return ("", source)
        }
        return (valueString, source)
    }

    var storedType: Any {
        return Value.self
    }
}

private protocol OverridableProperty {
    func override(with data: Data?) throws
    func makeSnapshot(for name: String) -> ConfigSnapshot
}
