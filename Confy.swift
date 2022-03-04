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
}

extension Bundle {
    static let confy = Bundle(for: Confy.self)
}
