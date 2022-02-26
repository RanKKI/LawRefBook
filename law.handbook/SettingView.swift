//
//  SettingView.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import SwiftUI

struct SettingView: View {

    var body: some View {
        List{
            Section(header: Text("内容来源"), footer: Text("如果您发现了任何错误，包括但不限于排版、错字、缺失内容，请使用以下联系方式告知开发者，以便修复")){
                Text("全国人民代表大会")
                Text("http://www.npc.gov.cn")
            }
            Section(header: Text("开发者")){
                Text("@RanKKI")
                Text("some.email@email.com")
            }
            Section(footer: Text("自豪地采用 SwiftUI")){
                Text("给 App 评分！")
                Text("[在 GitHub 上贡献](https://github.com/RanKKI/chinese.law.handbook)")
            }
        }
    }
}
