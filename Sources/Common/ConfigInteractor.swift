//
//  ConfigInteractor.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import Foundation

class ConfigInteractor {
    weak var display: ConfigDisplay?
    private var settings: Settings
    private var searchPhrase: String?
    private let groups: [ConfigGroup]

    init(groups: [ConfigGroup], settings: Settings) {
        guard !groups.map({ $0.configGroupName }).containsDuplicates() else {
            fatalError("ERROR! Config UI cannot handle multiple groups with the same name.")
        }
        self.groups = groups
        self.settings = settings
    }

    private func group(named: String) -> ConfigGroup? {
        return groups.first { $0.configGroupName.dropPrefixes(by: settings) == named }
    }

    private func configsDidUpdate(groups: [ConfigGroup]) {
        display?.display(config: makeViewModel(groups: groups))
    }

    private func makeViewModel(groups: [ConfigGroup]) -> ConfigViewModel {
        let sections: [ConfigViewModel.Section] = groups.map { group -> ConfigViewModel.Section in
            let title = group.configGroupName.dropPrefixes(by: settings)
            let elements = group.snapshots
                .filter({ [settings] config -> Bool in
                    if let searchPhrase = self.searchPhrase, searchPhrase != "" {
                        var wordsToCheck = [config.name]
                        if settings.search.matchWithSectionTitle {
                            wordsToCheck.append(group.configGroupName)
                        }
                        return wordsToCheck.map { $0.lowercased() }.contains { $0.contains(searchPhrase.lowercased()) }
                    } else {
                        return true
                    }
                })
                .sorted { $0.name < $1.name }
            return ConfigViewModel.Section(title: title, elements: elements)
        }
        return ConfigViewModel(sections: sections)
    }
}

extension ConfigInteractor: ConfigUseCase {

    func load() {
        configsDidUpdate(groups: groups)
    }

    func search(for phrase: String) {
        searchPhrase = phrase
        display?.display(config: makeViewModel(groups: groups))
    }

    func overrideConfig(groupName: String, key: String, with newValue: String) {
        do {
            try group(named: groupName)?.override(propertyName: key, with: newValue)
            configsDidUpdate(groups: groups)
        } catch {
            display?.errorAlert(title: "Failed to override \(key)", message: error.localizedDescription)
        }
    }

    func resetConfig(groupName: String, key: String) {
        group(named: groupName)?.reset(propertyName: key)
        configsDidUpdate(groups: groups)
    }

    func resetAllConfigs() {
        groups.forEach { $0.resetAll() }
        configsDidUpdate(groups: groups)
    }
}

extension Array where Element: Hashable {
    func containsDuplicates() -> Bool {
        Set(self).count < count
    }
}

private extension String {
    func dropPrefixes(by settings: Settings) -> String {
        let separator = Character(".") // Swift type names use dot separated segments
        if settings.list.dropSectionTitlePrefixes && self.contains(separator),
           let lastSegment = self.split(separator: separator).last {
            return String(lastSegment)
        }
        return self
    }
}
