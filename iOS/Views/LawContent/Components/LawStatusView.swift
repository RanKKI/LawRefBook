//
//  LawStatusView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct LawStatusView: View {

    var law: TLaw

    var body: some View {
        Group {
            if law.expired || !law.is_valid {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(law.expired ? .gray : .orange)
                    Text(law.expired ? "本法规已废止" : "本法规暂未施行")
                    Spacer()
                }
                .padding([.bottom], 8)
            }
        }
    }

}
