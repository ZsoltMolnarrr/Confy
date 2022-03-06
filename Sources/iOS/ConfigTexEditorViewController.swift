//
//  ConfigTexEditorViewController.swift
//  Confy
//
//  Created by Zsolt Molnar on 2021. 01. 11..
//

#if canImport(UIKit)

import UIKit

class ConfigTexEditorViewController: UITableViewController {
    var key: String?
    var value: String?
    var onSave: ((String) -> Void)?

    @IBOutlet private weak var keyLabel: UILabel!
    @IBOutlet private weak var valueTextView: UITextView!

    var returnKeyType: UIReturnKeyType = .default

    override func viewDidLoad() {
        super.viewDidLoad()

        keyLabel.text = key
        valueTextView.text = value
        valueTextView.returnKeyType = returnKeyType
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Automitcally start editing
        valueTextView.becomeFirstResponder()
    }

    private func save() {
        onSave?(valueTextView.text ?? "")
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        save()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension ConfigTexEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.returnKeyType == .done && text == "\n") {
            textView.resignFirstResponder()
            save()
        }
        return true
    }
}

#endif
