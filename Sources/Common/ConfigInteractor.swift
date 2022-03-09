//
//  ConfigInteractor.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import Foundation

class ConfigInteractor {
    weak var display: ConfigDisplay?
    private var preferences: Confy.Preferences
    private var searchPhrase: String?
    private let domains: [ConfigDomain]

    init(domains: [ConfigDomain], preferences: Confy.Preferences) {
        guard !domains.map({ $0.configDomainName }).containsDuplicates() else {
            fatalError("ERROR! Config UI cannot handle multiple domains with the same name.")
        }
        self.domains = domains
        self.preferences = preferences
    }

    private func domain(named: String) -> ConfigDomain? {
        return domains.first { $0.configDomainName == named }
    }

    private func configsDidUpdate(domains: [ConfigDomain]) {
        display?.display(config: makeViewModel(domains: domains))
    }

    private func makeViewModel(domains: [ConfigDomain]) -> ConfigViewModel {
        let sections: [ConfigViewModel.Section] = domains.map { domain -> ConfigViewModel.Section in
            let title = domain.configDomainName
            let elements = domain.snapshots
                .filter({ [preferences] config -> Bool in
                    if let searchPhrase = self.searchPhrase, searchPhrase != "" {
                        var wordsToCheck = [config.name]
                        if preferences.search.matchWithSectionTitle {
                            wordsToCheck.append(domain.configDomainName)
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
        configsDidUpdate(domains: domains)
    }

    func search(for phrase: String) {
        searchPhrase = phrase
        display?.display(config: makeViewModel(domains: domains))
    }

    func overrideConfig(domainName: String, key: String, with newValue: String) {
        do {
            try domain(named: domainName)?.override(propertyName: key, with: newValue)
            configsDidUpdate(domains: domains)
        } catch {
            display?.errorAlert(title: "Failed to override \(key)", message: error.localizedDescription)
        }
    }

    func resetConfig(domainName: String, key: String) {
        domain(named: domainName)?.reset(propertyName: key)
        configsDidUpdate(domains: domains)
    }

    func resetAllConfigs() {
        domains.forEach { $0.resetAll() }
        configsDidUpdate(domains: domains)
    }
}

extension Array where Element: Hashable {
    func containsDuplicates() -> Bool {
        Set(self).count < count
    }
}
