//
//  SettingView.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import SwiftUI

struct SettingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            Section(header: Text("测试1")) {
                Text("12321“")
            }
            Section(header: Text("测试1")) {
                Text("12321“")
            }
            Section(header: Text("测试1")) {
                Text("12321“")
            }
        }
    }
}
