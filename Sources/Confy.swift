//
//  Confy.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// 🔧 Module header for changing perferences and showing Config UI
public class Confy {
    // MARK: Public interface

    /// 🔩 Settings of the package
    public static var perferences = Preferences()

    /// 💾 Default used by ConfigDomains, to store overridden values.
    /// May be set to `nil` in order to disable persistent storage.
    /// If changing this value, make sure to perform it before initializing ConfigDomains.
    public static var defaultPersistentStore: PersistentConfigStore? = UserDefaultsConfigStore()

    #if canImport(UIKit)

    static let storyboard = UIStoryboard(name: "Confy", bundle: .confy)

    /// ➡️ Creates Config List screen, displaying configs of the given ConfigDomains, and pushes into the given navigation controller
    /// - Parameters:
    ///   - domains: the config elements of these to display and edit
    ///   - title: title of the config list screen
    ///   - navigationController: stack to push the screen into
    public static func pushConfigList(showing domains: ConfigDomain...,
                                      title: String? = nil,
                                      navigationController: UINavigationController) {
        let screen = makeConfigListScreen(domains: domains, title: title)
        navigationController.pushViewController(screen, animated: true)
    }

    /// ⬆️ Creates Config List screen, displaying configs of the given ConfigDomains, and modally presents on the topmost ViewController
    /// - Parameters:
    ///   - domains: the config elements of these to display and edit
    ///   - title: title of the config list screen
    public static func presentConfigList(showing domains: ConfigDomain..., title: String? = nil) {
        let screen = makeConfigListScreen(domains: domains, title: title)
        screen.addCloseButton()
        let navigationController = UINavigationController(rootViewController: screen)
        navigationController.navigationBar.prefersLargeTitles = true
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController.presentedViewController ?? rootViewController)?.present(navigationController, animated: true)
        }
    }

    /// 🏭 Creates Config List Screen
    /// May be used with custom presentation method
    /// - Parameters:
    ///   - domains: combined, the elemnets to display and edit
    ///   - title: title of the config list screen
    /// - Returns: Config List Screen
    public static func makeConfigListScreen(domains: [ConfigDomain], title: String?) -> ConfigViewController {
        let view = Confy.storyboard.instantiateViewController(withIdentifier: "list") as! ConfigViewController
        let interactor = ConfigInteractor(domains: domains)
        let presenter = ConfigPresenter()
        view.useCase = interactor
        interactor.delegate = presenter
        presenter.display = view
        if title != nil {
            view.title = title
        }
        return view
    }

    #endif
}

extension Confy {
    public struct Preferences {
        // var ... = ...
    }
}

extension Bundle {
    static let confy = Bundle(for: Confy.self)
}
