//
//  UIImage.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import UIKit

extension UIImage {

    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions((view.frame.size), false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }

}
