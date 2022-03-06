//
//  ConfigUseCase.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import Foundation

protocol ConfigUseCase: AnyObject {
    func load()
    func search(for phrase: String)
    func overrideConfig(domain: String, key: String, with newValue: String)
    func resetConfig(domain: String, key: String)
    func resetAllConfigs()
}

protocol ConfigUseCaseDelegate: AnyObject {
    func didSearch(domains: [ConfigDomain], phrase: String)
    func configsDidUpdate(domains: [ConfigDomain])
    func failedToOverride(key: String, error: Error)
}

protocol ConfigDisplay: AnyObject {
    func display(config: ConfigViewModel)
    func errorAlert(title: String, message: String)
}

struct ConfigViewModel {
    let sections: [Section]

    struct Section {
        public let title: String
        public let configs: [Config]
    }

    struct Config {
        public let domain: String
        public let name: String
        public let value: String
        public let source: ConfigSourceKind
    }
}
