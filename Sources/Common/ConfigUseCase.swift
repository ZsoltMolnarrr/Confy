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
    func overrideConfig(groupName: String, key: String, with newValue: String)
    func resetConfig(groupName: String, key: String)
    func resetAllConfigs()
}

protocol ConfigDisplay: AnyObject {
    func display(config: ConfigViewModel)
    func errorAlert(title: String, message: String)
}

struct ConfigViewModel {
    let sections: [Section]
    struct Section {
        public let title: String
        public let elements: [ConfigSnapshot]
    }
}
