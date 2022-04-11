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

/// 👋 Show/create ConfigViewController, change defaults
public class Confy {
    // MARK: Public interface

    /// 🔩 Settings to be used by default
    public static var settings = Settings()

    #if canImport(UIKit)

    /// ➡️ Creates Config List screen, displaying configs of the given ConfigGroups, and pushes into the given navigation controller
    /// - Parameters:
    ///   - groups: the config elements of these to display and edit
    ///   - title: title of the config list screen
    ///   - navigationController: stack to push the screen into
    public static func pushConfigList(showing groups: ConfigGroupProtocol...,
                                      title: String? = nil,
                                      navigationController: UINavigationController,
                                      settings: Settings? = nil) {
        pushConfigList(showing: groups, title: title, navigationController: navigationController, settings: settings)
    }

    /// ➡️ Creates Config List screen, displaying configs of the given ConfigGroups, and pushes into the given navigation controller
    /// - Parameters:
    ///   - groups: the config elements of these to display and edit
    ///   - title: title of the config list screen
    ///   - navigationController: stack to push the screen into
    public static func pushConfigList(showing groups: [ConfigGroupProtocol],
                                      title: String? = nil,
                                      navigationController: UINavigationController,
                                      settings: Settings? = nil) {
        let screen = makeConfigListScreen(groups: groups, title: title, settings: settings)
        navigationController.pushViewController(screen, animated: true)
    }

    /// ⬆️ Creates Config List screen, displaying configs of the given ConfigGroups, and modally presents on the topmost ViewController
    /// - Parameters:
    ///   - groups: the config elements of these to display and edit
    ///   - title: title of the config list screen
    public static func presentConfigList(showing groups: ConfigGroupProtocol..., title: String? = nil, settings: Settings? = nil) {
        presentConfigList(showing: groups, title: title, settings: settings)
    }

    /// ⬆️ Creates Config List screen, displaying configs of the given ConfigGroups, and modally presents on the topmost ViewController
    /// - Parameters:
    ///   - groups: the config elements of these to display and edit
    ///   - title: title of the config list screen
    public static func presentConfigList(showing groups: [ConfigGroupProtocol], title: String? = nil, settings: Settings? = nil) {
        let screen = makeConfigListScreen(groups: groups, title: title, settings: settings)
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
    ///   - groups: combined, the elemnets to display and edit
    ///   - title: title of the config list screen
    /// - Returns: Config List Screen
    public static func makeConfigListScreen(groups: [ConfigGroupProtocol], title: String?, settings: Settings? = nil) -> ConfigViewController {
        let resolvedSettings = settings ?? Self.settings
        let view = Confy.storyboard.instantiateViewController(withIdentifier: "list") as! ConfigViewController
        let interactor = ConfigInteractor(groups: groups, settings: resolvedSettings)
        view.useCase = interactor
        interactor.display = view
        view.settings = resolvedSettings
        if title != nil {
            view.title = title
        }
        return view
    }

    #endif
}

extension Confy {
    #if canImport(UIKit)
    static let storyboard = UIStoryboard(name: "Confy", bundle: .confy)
    #endif
}

extension Bundle {
    static let confy = Bundle(for: Confy.self)
}
