//
//  Confy.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation
import UIKit

/// 🔧 Module header for changing perferences and showing Config UI
public class Confy {
    // MARK: Public interface

    /// 🔩 Settings of the package
    public static var perferences = Preferences()

    /// 💾 Default store used by ConfigDomains
    /// ConfigDomains not overriding the `configStore` property use this reference.
    /// If changing this value, make sure to perform it before initializing ConfigDomains.
    public static var defaultPersistentStore = UserDefaultsConfigStore()

    /// ➡️ Creates Config List screen, displaying configs of the given ConfigDomain, and pushes into the given navigation controller.
    /// - Parameters:
    ///   - domain: the config elements of which to display and edit
    ///   - title: title of the config list screen
    ///   - navigationController: stack to push the screen into
    public static func addScreen(domain: ConfigDomain, title: String? = nil, into navigationController: UINavigationController) {
        addScreen(domains: [domain], title: title, into: navigationController)
    }

    /// ➡️ Creates Config List screen, displaying configs of the given ConfigDomains, and pushes into the given navigation controller.
    /// - Parameters:
    ///   - domains: combined, the elemnts to display and edit
    ///   - title: title of the config list screen
    ///   - navigationController: stack to push the screen into
    public static func addScreen(domains: [ConfigDomain], title: String? = nil, into navigationController: UINavigationController) {
        let view = Confy.storyboard.instantiateViewController(withIdentifier: "list") as! ConfigViewController
        let interactor = ConfigInteractor(domains: domains)
        let presenter = ConfigPresenter()
        view.useCase = interactor
        interactor.delegate = presenter
        presenter.display = view

        if title != nil {
            view.title = title
        }
        navigationController.pushViewController(view, animated: true)
    }

    // MARK: Internals
    static let storyboard = UIStoryboard(name: "Config", bundle: .confy)
}

extension Confy {
    public struct Preferences {
        // var ... = ...
    }
}

extension Bundle {
    static let confy = Bundle(for: Confy.self)
}
