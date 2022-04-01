import Foundation
import SwiftUI

private let ContributorsText = String(format: "特别感谢以下朋友的贡献: %@", Contributors.isEmpty ? "欢迎你来贡献！" : Contributors.joined(separator: ", "))

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
            Text(COPYRIGHT_DECLARE)
                .listRowBackground(Color.clear)
                .font(.footnote)
            
            Text(ContributorsText)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .multilineTextAlignment(.leading)
                .font(.footnote)
                .padding(.top, 16)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    dismiss()
                }
            }
        }
    }
}
