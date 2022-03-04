//
//  ConfigUseCase.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import Foundation

public protocol ConfigUseCase: AnyObject {
    func load()
    func search(for phrase: String)
    func overrideConfig(domain: String, key: String, with newValue: String)
    func resetConfig(domain: String, key: String)
    func resetAllConfigs()
}

public protocol ConfigUseCaseDelegate: AnyObject {
    func didSearch(domains: [ConfigDomain], phrase: String)
    func configsDidUpdate(domains: [ConfigDomain])
    func failedToOverride(key: String, error: Error)
}

public protocol ConfigDisplay: AnyObject {
    func display(config: ConfigViewModel)
    func errorAlert(title: String, message: String)
}

public struct ConfigViewModel {
    public let sections: [Section]

    public struct Section {
        public let title: String
        public let configs: [Config]
    }

    public struct Config {
        public let domain: String
        public let name: String
        public let value: String
        public let source: SourceKind
    }
}
