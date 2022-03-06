//
//  ConfigStore.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

/// Stores Config overrides at a persistent location.
public protocol PersistentConfigStore {
    func save(domain: String, key: String, value: Data)
    func load(domain: String) -> [String: Any]
    func removeValue(domain: String, key: String)
}

/// Stores Config overrides in UserDefaults
public class UserDefaultsConfigStore {
    private let key: String
    private let userDefaults: UserDefaults

    public init(key: String = "confy.overrides", userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
    }

    private func dictionary(of domain: String) -> [String: Any] {
        let mainDict = userDefaults.dictionary(forKey: key) ?? [:]
        let domainDict = (mainDict[domain] as? [String: Any]) ?? [:]
        return domainDict
    }

    private func save(dictionary: [String: Any], for domain: String) {
        var mainDict = userDefaults.dictionary(forKey: key) ?? [:]
        mainDict[domain] = dictionary
        userDefaults.set(mainDict, forKey: key)
    }
}

extension UserDefaultsConfigStore: PersistentConfigStore {
    public func save(domain: String, key: String, value: Data) {
        var dict = dictionary(of: domain)
        dict[key] = value
        save(dictionary: dict, for: domain)
    }

    public func load(domain: String) -> [String: Any] {
        return dictionary(of: domain)
    }

    public func removeValue(domain: String, key: String) {
        var dict = dictionary(of: domain)
        dict.removeValue(forKey: key)
        save(dictionary: dict, for: domain)
    }
}
