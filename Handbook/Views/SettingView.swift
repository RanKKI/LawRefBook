//
//  SettingView.swift
//  law.handbook
//
//  Created by Hugh Liu on 26/2/2022.
//

import Foundation
import SwiftUI

let desc = """
根据《中华人民共和国著作权法》第五条，本作品不适用于该法。如不受其他法律、法规保护，本作品在中国大陆和其他地区属于公有领域。
不适用于《中华人民共和国著作权法》的作品包括：
（一）法律、法规，国家机关的决议、决定、命令和其他具有立法、行政、司法性质的文件，及其官方正式译文；
（二）单纯事实消息；
（三）历法、通用数表、通用表格和公式。
"""

let DeveloperMail = "rankki.dev@icloud.com"

struct SettingView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List{
            Section(header: Text("内容来源"), footer: Text("如果您发现了任何错误，包括但不限于排版、错字、缺失内容，请使用以下联系方式告知开发者，以便修复")){
                Text("国家法律法规数据库")
                Text("https://flk.npc.gov.cn")
            }
            Section(header: Text("开发者")){
                Text("@RanKKI")
                Text(DeveloperMail)
                    .foregroundColor(.accentColor)
                    .underline()
                    .onTapGesture {
                        OpenMail(subject: "问题反馈：", body: "")
                    }
            }
            Section(footer: Text("自豪地采用 SwiftUI")){
                Text("给 App 评分！")
                Text("[在 GitHub 上贡献](https://github.com/RanKKI/chinese.law.handbook)")
            }

            Text(desc)
                .listRowBackground(Color.clear)
                .font(.footnote)
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    dismiss()
                }
            }
        }
    }
}
