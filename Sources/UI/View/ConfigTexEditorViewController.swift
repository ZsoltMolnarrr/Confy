//
//  ConfigTexEditorViewController.swift
//  Confy
//
//  Created by Zsolt Molnar on 2021. 01. 11..
//

import UIKit

class ConfigTexEditorViewController: UITableViewController {
    var key: String?
    var value: String?
    var onSave: ((String) -> Void)?

    @IBOutlet private weak var keyLabel: UILabel!
    @IBOutlet private weak var valueTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        keyLabel.text = key
        valueTextView.text = value
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Automitcally start editing
        valueTextView.becomeFirstResponder()
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        onSave?(valueTextView.text ?? "")
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
}
