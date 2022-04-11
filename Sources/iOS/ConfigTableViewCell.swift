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

    func configure(viewModel: ConfigSnapshot, settings: Settings.List) {
        title.text = viewModel.name

        source.isHidden = !settings.showCurrentSource
        if settings.showCurrentSource {
            var sourceColor = UIColor.darkGray
            switch viewModel.source {
            case .localOverride:
                sourceColor = settings.overrideColor
            case .custom(let name):
                if let customColor = settings.sourcePalette[name] {
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
