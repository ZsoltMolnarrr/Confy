//
//  ConfigPresenter.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import Foundation

class ConfigPresenter {
    weak var display: ConfigDisplay?

    private var searchPhrase: String?

    func didSearch(domains: [ConfigDomain], phrase: String) {
        searchPhrase = phrase
        display?.display(config: makeViewModel(domains: domains))
    }

    func configsDidUpdate(domains: [ConfigDomain]) {
        display?.display(config: makeViewModel(domains: domains))
    }

    private func makeViewModel(domains: [ConfigDomain]) -> ConfigViewModel {
        let sections: [ConfigViewModel.Section] = domains.map { domain -> ConfigViewModel.Section in
            let title = domain.configDomainName
            let elements = domain.snapshots
                .filter({ config -> Bool in
                    if let searchPhrase = self.searchPhrase, searchPhrase != "" {
                        return config.name.lowercased().contains(searchPhrase.lowercased())
                    } else {
                        return true
                    }
                })
                .sorted { $0.name < $1.name }
            return ConfigViewModel.Section(title: title, elements: elements)
        }
        return ConfigViewModel(sections: sections)
    }

    func failedToOverride(key: String, error: Error) {
        display?.errorAlert(title: "Failed to override \(key)", message: error.localizedDescription)
    }
}
