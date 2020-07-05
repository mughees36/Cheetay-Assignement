//
//  UIView+Extensions.swift
//  assignment
//
//  Created by Mughees Mustafa on 03/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import UIKit
extension UIView {
    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
