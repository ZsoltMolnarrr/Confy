//
//  ConfigStore.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

/// Stores Config overrides at a persistent location.
public protocol PersistentConfigStore {
    func save(group: String, key: String, value: Data)
    func load(group: String) -> [String: Any]
    func removeValue(group: String, key: String)
}

/// Stores Config overrides in UserDefaults
public class UserDefaultsConfigStore {
    private let key: String
    private let userDefaults: UserDefaults

    public init(key: String = "confy.overrides", userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
    }

    private func dictionary(of group: String) -> [String: Any] {
        let mainDict = userDefaults.dictionary(forKey: key) ?? [:]
        let groupDict = (mainDict[group] as? [String: Any]) ?? [:]
        return groupDict
    }

    private func save(dictionary: [String: Any], for group: String) {
        var mainDict = userDefaults.dictionary(forKey: key) ?? [:]
        mainDict[group] = dictionary
        userDefaults.set(mainDict, forKey: key)
    }
}

extension UserDefaultsConfigStore: PersistentConfigStore {
    public func save(group: String, key: String, value: Data) {
        var dict = dictionary(of: group)
        dict[key] = value
        save(dictionary: dict, for: group)
    }

    public func load(group: String) -> [String: Any] {
        return dictionary(of: group)
    }

    public func removeValue(group: String, key: String) {
        var dict = dictionary(of: group)
        dict.removeValue(forKey: key)
        save(dictionary: dict, for: group)
    }
}
