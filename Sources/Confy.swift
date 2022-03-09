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

/// 🔧 Module header for changing preferences and showing Config UI
public class Confy {
    // MARK: Public interface

    /// 🔩 Settings of the package
    public static var preferences = Preferences()

    /// 💾 Default used by ConfigDomains, to store overridden values.
    /// May be set to `nil` in order to disable persistent storage.
    /// If changing this value, make sure to perform it before initializing ConfigDomains.
    public static var defaultPersistentStore: PersistentConfigStore? = UserDefaultsConfigStore()

    #if canImport(UIKit)

    /// ➡️ Creates Config List screen, displaying configs of the given ConfigDomains, and pushes into the given navigation controller
    /// - Parameters:
    ///   - domains: the config elements of these to display and edit
    ///   - title: title of the config list screen
    ///   - navigationController: stack to push the screen into
    public static func pushConfigList(showing domains: ConfigDomain...,
                                      title: String? = nil,
                                      navigationController: UINavigationController,
                                      preferences: Preferences? = nil) {
        pushConfigList(showing: domains, title: title, navigationController: navigationController, preferences: preferences)
    }

    /// ➡️ Creates Config List screen, displaying configs of the given ConfigDomains, and pushes into the given navigation controller
    /// - Parameters:
    ///   - domains: the config elements of these to display and edit
    ///   - title: title of the config list screen
    ///   - navigationController: stack to push the screen into
    public static func pushConfigList(showing domains: [ConfigDomain],
                                      title: String? = nil,
                                      navigationController: UINavigationController,
                                      preferences: Preferences? = nil) {
        let screen = makeConfigListScreen(domains: domains, title: title, preferences: preferences)
        navigationController.pushViewController(screen, animated: true)
    }

    /// ⬆️ Creates Config List screen, displaying configs of the given ConfigDomains, and modally presents on the topmost ViewController
    /// - Parameters:
    ///   - domains: the config elements of these to display and edit
    ///   - title: title of the config list screen
    public static func presentConfigList(showing domains: ConfigDomain..., title: String? = nil, preferences: Preferences? = nil) {
        presentConfigList(showing: domains, title: title, preferences: preferences)
    }

    /// ⬆️ Creates Config List screen, displaying configs of the given ConfigDomains, and modally presents on the topmost ViewController
    /// - Parameters:
    ///   - domains: the config elements of these to display and edit
    ///   - title: title of the config list screen
    public static func presentConfigList(showing domains: [ConfigDomain], title: String? = nil, preferences: Preferences? = nil) {
        let screen = makeConfigListScreen(domains: domains, title: title, preferences: preferences)
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
    public static func makeConfigListScreen(domains: [ConfigDomain], title: String?, preferences: Preferences? = nil) -> ConfigViewController {
        let resolvedPreferences = preferences ?? Self.preferences
        let view = Confy.storyboard.instantiateViewController(withIdentifier: "list") as! ConfigViewController
        let interactor = ConfigInteractor(domains: domains, preferences: resolvedPreferences)
        view.useCase = interactor
        interactor.display = view
        view.preferences = resolvedPreferences
        if title != nil {
            view.title = title
        }
        return view
    }

    #endif
}

extension Confy {
    public struct Preferences {
        public init() { }
        /// 🔎 Search options
        public var search = Search()
        public struct Search {
            /// 🗂 Find items where embedding section title matches
            public var matchWithSectionTitle = true
        }
        #if canImport(UIKit)
        /// 📜 Appearance of list and items
        public var list = List()
        public struct List {
            public init() { }
            /// 🥢 Determines wheter of not the current source of a config is shown
            public var showCurrentSource = true
            /// 🎈 Text color of the source label in case override is applied
            public var overrideColor: UIColor = .red
            /// 🎨 Assign specific colors to custom config sources with matching names.
            /// For example: `["Firebase" : .orange]`
            public var sourcePalette: [String: UIColor] = [:]
        }
        #endif
    }
}

extension Confy {
    #if canImport(UIKit)
    static let storyboard = UIStoryboard(name: "Confy", bundle: .confy)
    #endif
}

extension Bundle {
    static let confy = Bundle(for: Confy.self)
}
