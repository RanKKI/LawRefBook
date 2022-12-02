//
//  CopyLawTextButton.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct CopyLawTextButton: View {
    
    var law: TLaw
    var text: String
    
    var body: some View {
        Button {
            let message = String(format: "%@\n\n%@", law.name, text)
            UIPasteboard.general.setValue(message, forPasteboardType: "public.plain-text")
        } label: {
            Label("复制", systemImage: "doc")
        }
    }
    
}
