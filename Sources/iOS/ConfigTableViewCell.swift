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

    func configure(viewModel: ConfigSnapshot, preferences: Confy.Preferences.ListItem) {
        title.text = viewModel.name

        source.isHidden = !preferences.showCurrentSource
        if preferences.showCurrentSource {
            var sourceColor = UIColor.darkGray
            switch viewModel.source {
            case .localOverride:
                sourceColor = preferences.overrideColor
            case .custom(let name):
                if let customColor = preferences.sourcePalette[name] {
                    sourceColor = customColor
                }
            default:
                break
            }
            source.textColor = sourceColor
            source.text = viewModel.source.name
        }
        
        detail.text = viewModel.encodedValue
    }
}

extension UINib {
    static let configTableViewCell = UINib(nibName: "ConfigTableViewCell", bundle: .confy)
}

#endif
