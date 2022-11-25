//
//  Thread.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation

func uiThread(action: @escaping () -> Void){
    DispatchQueue.main.async {
        action()
    }
}
