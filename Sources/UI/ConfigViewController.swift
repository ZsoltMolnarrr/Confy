//
//  ConfigViewController.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private var searchController: UISearchController?
    private weak var editor: ConfigTexEditorViewController?
    var useCase: ConfigUseCase!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        navigationController?.navigationBar.prefersLargeTitles = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        addSearchController()
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

    private var sections: [ConfigViewModel.Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var overrideCount: Int {
        var overrides = 0
        sections.forEach { section in
            overrides += section.configs.filter { $0.source == .localOverride }.count
        }
        return overrides
    }

    private func config(for indexPath: IndexPath) -> ConfigViewModel.Config {
        return sections[indexPath.section].configs[indexPath.row]
    }

    private func copy(config: ConfigViewModel.Config) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = config.value
        let alert = UIAlertController(title: "Copied", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func edit(config: ConfigViewModel.Config) {
        let editor = Confy.storyboard.instantiateViewController(withIdentifier: "editor") as! ConfigTexEditorViewController
        editor.key = config.name
        editor.value = config.value
        editor.onSave = { [weak self] newValue in
            self?.useCase.overrideConfig(domain: config.domain, key: config.name, with: newValue)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(editor, animated: true)
        self.editor = editor
    }

    @IBAction func resetPressed(_ sender: UIBarButtonItem) {
        useCase.resetAllConfigs()
    }
}

extension ConfigViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].configs.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigTableViewCell") as! ConfigTableViewCell
        let viewModel = config(for: indexPath)
        cell.configure(viewModel: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = self.config(for: indexPath)
        let copy = UIContextualAction(style: .normal, title: "Copy") { _, _, completionHandler in
            completionHandler(true)
            self.copy(config: config)
        }
        copy.backgroundColor = .systemBlue

        let edit = UIContextualAction(style: .normal, title: "Edit") { _, _, completionHandler in
            completionHandler(true)
            self.edit(config: config)
        }
        edit.backgroundColor = .systemOrange

        let reset = UIContextualAction(style: .normal, title: "Reset") { _, _, completionHandler in
            completionHandler(true)
            self.useCase.resetConfig(domain: config.domain, key: config.name)
        }
        reset.backgroundColor = config.source == .localOverride ? .systemRed : .gray

        return UISwipeActionsConfiguration(actions: [reset, edit, copy])
    }
}

extension ConfigViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        useCase.search(for: searchController.searchBar.text ?? "")
    }
}

extension ConfigViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        edit(config: config(for: indexPath))
    }
}

extension ConfigViewController: ConfigDisplay {
    func display(config: ConfigViewModel) {
        sections = config.sections
        navigationItem.prompt = overrideCount > 0 ? "Currently \(overrideCount) values modified" : nil
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
