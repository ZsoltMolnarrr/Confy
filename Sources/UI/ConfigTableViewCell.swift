//
//  ConfigTableViewCell.swift
//  Confy
//
//  Created by Molnar Zsolt on 23/06/2020.
//

import UIKit

class ConfigTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var detail: UITextView!

    func configure(viewModel: ConfigViewModel.Config) {
        title.text = viewModel.name
        source.text = viewModel.source.name
        source.textColor = viewModel.source == .localOverride ? .red : .darkGray
        detail.text = viewModel.value
    }
}

extension UINib {
    static let configTableViewCell = UINib(nibName: "ConfigTableViewCell", bundle: .confy)
}