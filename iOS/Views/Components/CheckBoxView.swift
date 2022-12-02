//
//  CheckBoxView.swift
//  RefBook
//
//  Created by Hugh Liu on 22/6/2022.
//

import Foundation
import SwiftUI

struct CheckBoxView: View {

    @State
    var isOn = false

    var action: (Bool) -> Void

    var body: some View {
        ZStack(alignment: .center) {
            Image(systemName: "square")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            if isOn {
                Image(systemName: "checkmark")
            }
        }
        .onTapGesture {
            isOn.toggle()
            action(isOn)
        }
    }

}
