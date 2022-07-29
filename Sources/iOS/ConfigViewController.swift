//
//  ConfigViewController.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

#if canImport(UIKit)

import UIKit

public class ConfigViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private var searchController: UISearchController?
    private weak var editor: ConfigTexEditorViewController?
    var useCase: ConfigUseCase!
    var settings: Settings!

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        navigationController?.navigationBar.prefersLargeTitles = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if settings.search.isEnabled {
            addSearchController()
        }
        useCase.load()
    }

    func addSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search config"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    func addCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                           target: self,
                                                           action: #selector(close))
    }

    @objc func close() {
        navigationController?.dismiss(animated: true)
    }

    private var updateQueue = DispatchQueue(label: "ConfigViewController")
    private var plainDataSource: [ConfigViewModel.Section] = []

    private lazy var _diffingDataSource: AnyObject = {
        if #available(iOS 13.0, *) {
            let dataSource = StringSectionTableViewDiffibleDataSource<ConfigSnapshot>(tableView: self.tableView) { [settings] tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigTableViewCell") as! ConfigTableViewCell
                cell.configure(viewModel: item, settings: settings!.list)
                return cell
            }
            return dataSource
        } else {
            return NSObject()
        }
    }()

    @available(iOS 13.0, *)
    var diffingDataSource: StringSectionTableViewDiffibleDataSource<ConfigSnapshot> {
        return _diffingDataSource as! StringSectionTableViewDiffibleDataSource<ConfigSnapshot>
    }

    private var overrideCount: Int {
        var overrides = 0
        plainDataSource.forEach { section in
            overrides += section.elements.filter { $0.source == .localOverride }.count
        }
        return overrides
    }

    private func groupName(for indexPath: IndexPath) -> String {
        if #available(iOS 13.0, *) {
            return plainDataSource[indexPath.section].title
        } else {
            return plainDataSource[indexPath.section].title
        }
    }

    private func config(for indexPath: IndexPath) -> ConfigSnapshot {
        if #available(iOS 13.0, *) {
            return diffingDataSource.itemIdentifier(for: indexPath)!
        } else {
            return plainDataSource[indexPath.section].elements[indexPath.row]
        }
    }

    private func copy(config: ConfigSnapshot) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = config.encodedValue
        let alert = UIAlertController(title: "Copied", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func edit(config: ConfigSnapshot, groupName: String) {
        let editor = Confy.storyboard.instantiateViewController(withIdentifier: "editor") as! ConfigTexEditorViewController
        editor.key = config.name
        editor.value = config.encodedValue
        editor.onSave = { [weak self] newValue in
            self?.useCase.overrideConfig(groupName: groupName, key: config.name, with: newValue)
            self?.navigationController?.popViewController(animated: true)
        }
        if isPrimitive(value: config.value) {
            editor.returnKeyType = .done
        }
        navigationController?.pushViewController(editor, animated: true)
        self.editor = editor
    }

    @IBAction func resetPressed(_ sender: UIBarButtonItem) {
        useCase.resetAllConfigs()
    }
}

extension ConfigViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return plainDataSource.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plainDataSource[section].elements.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return plainDataSource[section].title
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigTableViewCell") as! ConfigTableViewCell
        let viewModel = config(for: indexPath)
        cell.configure(viewModel: viewModel, settings: settings.list)
        return cell
    }

    public func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = self.config(for: indexPath)
        let groupName = groupName(for: indexPath)
        let copy = UIContextualAction(style: .normal, title: "Copy") { _, _, completionHandler in
            completionHandler(true)
            self.copy(config: config)
        }
        copy.backgroundColor = .systemBlue

        let edit = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler in
            completionHandler(true)
            self.edit(config: config, groupName: groupName)
        }
        edit.backgroundColor = .systemOrange

        let reset = UIContextualAction(style: .normal, title: "Reset") { _, _, completionHandler in
            completionHandler(true)
            self.useCase.resetConfig(groupName: groupName, key: config.name)
        }
        reset.backgroundColor = config.source == .localOverride ? .systemRed : .gray

        return UISwipeActionsConfiguration(actions: [reset, edit, copy])
    }
}

extension ConfigViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        useCase.search(for: searchController.searchBar.text ?? "")
    }
}

extension ConfigViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let groupName = groupName(for: indexPath)
        edit(config: config(for: indexPath), groupName: groupName)
    }
}

extension ConfigViewController: ConfigDisplay {
    func display(config: ConfigViewModel) {
        if #available(iOS 13.0, *) {
            let oldData = plainDataSource
            var snapshot = NSDiffableDataSourceSnapshot<String, ConfigSnapshot>()
            snapshot.appendSections(config.sections.map { $0.title })
            config.sections.forEach { section in
                snapshot.appendItems(section.elements.map { $0 }, toSection: section.title)
            }
            var reloadItems = [ConfigSnapshot]()
            for newSection in config.sections {
                if let oldSection = oldData.first(where: { $0.title == newSection.title }) {
                    for newElement in newSection.elements {
                        if let existingAsOldElement = oldSection.elements.first(where: { $0.name == newElement.name }),
                           newElement != existingAsOldElement {
                            reloadItems.append(newElement)
                        }
                    }
                }
            }
            snapshot.reloadItems(reloadItems)
            self.plainDataSource = config.sections
            self.diffingDataSource.apply(snapshot, animatingDifferences: true)
        } else {
            plainDataSource = config.sections
            tableView.reloadData()
        }
        let title = "Currently \(overrideCount) \(overrideCount > 1 ? "values" : "value") modified"
        navigationItem.prompt = overrideCount > 0 ? title : nil
    }

    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ConfigViewController {
    @objc
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let alertView = (self.presentedViewController as? UIAlertController)?.view else {
                return
        }

        alertView.frame.origin.y -= keyboardSize.height / 2
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let alertView = (self.presentedViewController as? UIAlertController)?.view else {
                return
        }

        alertView.frame.origin.y += keyboardSize.height / 2
    }
}

extension ConfigSnapshot {
    func diffId(in section: ConfigViewModel.Section) -> String {
        return section.title + "/" + name
    }
}

extension ConfigSnapshot: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name &&
        lhs.source == rhs.source &&
        lhs.encodedValue == rhs.encodedValue
    }
}

extension ConfigSnapshot: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

@available(iOS 13.0, *)
class StringSectionTableViewDiffibleDataSource<Item: Hashable>: UITableViewDiffableDataSource<String, Item> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let snapshot = snapshot()
        guard snapshot.sectionIdentifiers.indices.contains(section) else { return nil }
        return snapshot.sectionIdentifiers[section]
    }
}

#endif
