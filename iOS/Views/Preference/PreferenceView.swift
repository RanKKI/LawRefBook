import Foundation
import SwiftUI

private let ContributorsText = String(format: "特别感谢以下朋友的贡献: %@",
                                      Contributors.isEmpty ? "欢迎你来贡献！" : Contributors.joined(separator: ", "))

struct PreferenceView: View {

    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject
    private var preference = Preference.shared

    var body: some View {
        List {
            Section(header: Text("内容来源"), footer: Text("如果您发现了任何错误，包括但不限于排版、错字、缺失内容，请使用以下联系方式告知开发者，以便修复")) {
                SafariLinkView(title: "国家法律法规数据库", url: "https://flk.npc.gov.cn")
                SafariLinkView(title: "最高人民法院", url: "https://www.court.gov.cn")
                NavigationLink {
                    DLCListView(vm: .init())
                } label: {
                    Text("DLC")
                }
            }
            Section(header: Text("偏好设置")) {
                HStack {
                    Text("分组方式")
                    Spacer()
                    Picker("", selection: $preference.groupingMethod) {
                        ForEach(LawGroupingMethod.allCases, id: \.self) {
                            Text($0.rawValue)
                       }
                    }
                    .pickerStyle(.menu)
                }
                HStack {
                    Text("搜索历史")
                    Spacer()
                    Picker("", selection: $preference.searchHistoryType) {
                        ForEach(SearchHistoryType.allCases, id: \.self) {
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
            Section(header: Text("开发者")) {
                Text("@RanKKI")
                Text(DeveloperMail)
                    .foregroundColor(.accentColor)
                    .underline()
                    .onTapGesture {
                        Mail.reportIssue()
                    }
            }

            Section(footer: Text("自豪地采用 SwiftUI")) {
                Button("给 App 评分！") {
                    if let url = URL(string: "itms-apps://apple.com/app/id1612953870") {
                        UIApplication.shared.open(url)
                    }
                }
                Text("[在 GitHub 上贡献](https://github.com/RanKKI/LawRefBook)")
            }

            Section(header: Text("其他")) {
                NavigationLink {
                    LicenseView()
                } label: {
                    Text("LICENSE")
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

            InAppPurchaseView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CloseSheetItem {
                    dismiss()
                }
            }
        }
    }
}
