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

let Contributors: [String] = [
    "@文涛",
    "@nuomi1",
]
let ContributorsText = String(format: "贡献者: %@", Contributors.isEmpty ? "欢迎你来贡献！" : Contributors.joined(separator: ","))

let DeveloperMail = "rankki.dev@icloud.com"

struct SettingView: View {

    @Environment(\.dismiss) var dismiss

    @AppStorage("defaultGroupingMethod", store: .standard)
    private var groupingMethod = LawGroupingMethod.department

    var body: some View {
        List{
            Section(header: Text("内容来源"), footer: Text("如果您发现了任何错误，包括但不限于排版、错字、缺失内容，请使用以下联系方式告知开发者，以便修复")){
                Text("国家法律法规数据库")
                Text("https://flk.npc.gov.cn")
            }
            Section(header: Text("偏好设置")) {
                HStack {
                    Text("分组方式")
                    Spacer()
                    Picker("分组方式", selection: $groupingMethod) {
                        ForEach(LawGroupingMethod.allCases, id: \.self) {
                            Text($0.rawValue)
                       }
                    }
                    .pickerStyle(.menu)
                }
                NavigationLink {
                    FontSettingView()
                        .navigationBarTitle("字体设置")
                } label: {
                    Text("字体设置")
                }
            }
            Section(header: Text("开发者"), footer: Text(ContributorsText)){
                Text("@RanKKI")
                Text(DeveloperMail)
                    .foregroundColor(.accentColor)
                    .underline()
                    .onTapGesture {
                        OpenMail(subject: "问题反馈：", body: "")
                    }
            }
            Section(footer: Text("自豪地采用 SwiftUI")){
                Button("给 App 评分！") {
                    AppStoreReviewManager.requestReviewIfAppropriate()
                }
                Text("[在 GitHub 上贡献](https://github.com/RanKKI/LawRefBook)")
            }
            Section(header: Text("其他")) {
                NavigationLink {
                    LicenseView()
                } label: {
                    Text("LICENSE")
                }
                Button {
                    LawProvider.shared.lawList.flatMap { $0 }
                        .forEach { uuid in
                            addLawContentToSpotlight(lawUUID: uuid)
                        }
                } label: {
                    Text("创建 Spotlight 索引")
                }
            }
            Text(desc)
                .listRowBackground(Color.clear)
                .font(.footnote)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    dismiss()
                }
            }
        }
        .onChange(of: groupingMethod) { val in
            LawProvider.shared.loadLawList()
        }
    }
}
