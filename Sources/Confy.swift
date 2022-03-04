//
//  Confy.swift
//  Confy
//
//  Created by Zsolt Molnár on 2022. 03. 04..
//

import Foundation
import UIKit

public class Confy {
    static let storyboard = UIStoryboard(name: "Config", bundle: .confy)

    public static func addScreen(domains: [ConfigDomain], title: String? = nil, into navigationController: UINavigationController) {
        let view = Confy.storyboard.instantiateViewController(withIdentifier: "list") as! ConfigViewController
        let interactor = ConfigInteractor(domains: domains)
        let presenter = ConfigPresenter()
        view.useCase = interactor
        interactor.delegate = presenter
        presenter.display = view

        if title != nil {
            view.title = title
        }
        navigationController.pushViewController(view, animated: true)
    }
}

extension Bundle {
    static let confy = Bundle(for: Confy.self)
}
