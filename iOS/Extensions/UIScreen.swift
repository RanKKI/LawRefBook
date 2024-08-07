//
//  UIScreen.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import UIKit

extension UIScreen {

   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size

}

extension UIDevice {
    static var idiom: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    static var isIpad: Bool {
        idiom == .pad
    }
    
    static var isiPhone: Bool {
        idiom == .phone
    }
}
