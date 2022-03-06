//
//  ConfigInteractor.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import Foundation

class ConfigInteractor: ConfigUseCase {
    // swiftlint:disable:next weak_delegate
    var delegate: ConfigUseCaseDelegate!

    private let domains: [ConfigDomain]

    init(domains: [ConfigDomain]) {
        self.domains = domains
    }

    private func domain(named: String) -> ConfigDomain? {
        return domains.first { $0.configDomainName == named }
    }

    func load() {
        delegate.configsDidUpdate(domains: domains)
    }

    func search(for phrase: String) {
        delegate.didSearch(domains: domains, phrase: phrase)
    }

    func overrideConfig(domain domainName: String, key: String, with newValue: String) {
        do {
            try domain(named: domainName)?.override(propertyName: key, with: newValue)
            delegate.configsDidUpdate(domains: domains)
        } catch {
            delegate.failedToOverride(key: key, error: error)
        }
    }

    func resetConfig(domain domainName: String, key: String) {
        domain(named: domainName)?.reset(propertyName: key)
        delegate.configsDidUpdate(domains: domains)
    }

    func resetAllConfigs() {
        domains.forEach { $0.resetAll() }
        delegate.configsDidUpdate(domains: domains)
    }
}
