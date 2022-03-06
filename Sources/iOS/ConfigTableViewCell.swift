//
//  ConfigTableViewCell.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

#if canImport(UIKit)

import UIKit

class ConfigTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var detail: UITextView!

    func configure(viewModel: ConfigSnapshot) {
        title.text = viewModel.name
        source.text = viewModel.source.name
        source.textColor = viewModel.source == .localOverride ? .red : .darkGray
        detail.text = viewModel.encodedValue
    }
}

extension UINib {
    static let configTableViewCell = UINib(nibName: "ConfigTableViewCell", bundle: .confy)
}

#endif
