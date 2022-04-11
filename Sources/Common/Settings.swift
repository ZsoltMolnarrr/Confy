//
//  Settings.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 04. 09..
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// 🔩 Apperance and behaviour settings of ConfigViewController
public struct Settings {
    public init() { }

    /// 💾 Options of persistently storing config overrides
    public var persistence = Persistence()
    public struct Persistence {
        public init() { }
        /// 🐛  If set to true, overriden configs will be restored from persistent store only in `DEBUG` builds.
        /// If changing this value, make sure to perform it before initializing ConfigGroups.
        public var restoreOnlyInDebugBuildConfiguration = true
        /// 🏠 Default used by ConfigGroups, to store overridden values.
        /// May be set to `nil` in order to disable persistent storage.
        /// If changing this value, make sure to perform it before initializing ConfigGroups.
        public var defaultStore: PersistentConfigStore? = UserDefaultsConfigStore()
    }

    /// 🔎 Search options
    public var search = Search()
    public struct Search {
        public init() { }
        /// 🔎 Show search bar on ConfigViewControllers
        public var isEnabled = true
        /// 🗂 Find items where embedding section title matches
        public var matchWithSectionTitle = true
    }

    #if canImport(UIKit)
    /// 📜 Appearance of list and items
    public var list = List()
    public struct List {
        public init() { }
        /// 🔪 Removes prefixes from section titles. For example:
        /// "AppConfig.MyFeature" -> "MyFeature"
        public var dropSectionTitlePrefixes = true
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
