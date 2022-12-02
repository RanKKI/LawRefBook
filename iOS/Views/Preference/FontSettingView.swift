import SwiftUI

private let exampleLines = [
    "第二百一十四条 不动产物权的设立、变更、转让和消灭，依照法律规定应当登记的，自记载于不动产登记簿时发生效力。",
    "第二百一十五条 当事人之间订立有关设立、变更、转让和消灭不动产物权的合同，除法律另有规定或者当事人另有约定外，自合同成立时生效；未办理物权登记的，不影响合同效力。",
    "第二百一十六条 不动产登记簿是物权归属和内容的根据。"
]

private struct AdjustSteppter<Value: Numeric>: View {

    var title: String

    @Binding
    var value: Value

    var step: Value

    var valueStr: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let spelledOutNumber = formatter.string(for: value)!
        return spelledOutNumber
    }

    var body: some View {
        Group {
            Stepper {
                Text("\(title): \(valueStr)")
            } onIncrement: {
                value += step
            } onDecrement: {
                value -= step
            }
            Divider()
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8))
    }
}

struct FontSettingView: View {

    @ObservedObject
    private var preference = Preference.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AdjustSteppter(title: "正文大小", value: $preference.contentFontSize, step: 1)
                AdjustSteppter(title: "字间距", value: $preference.tracking, step: 0.1)
                AdjustSteppter(title: "行间距", value: $preference.spacing, step: 0.1)
                AdjustSteppter(title: "法条间距", value: $preference.lineSpacing, step: 1)
                Group {
                    Text("中华人民共和国民法典").displayMode(.Title)
                    Text("物权编").displayMode(.Title)
                    Text("第一分编  通则").displayMode(.Header, indent: 1)
                    Text("第一章  一般规定").displayMode(.Header, indent: 2)
                    Divider()
                    VStack(alignment: .leading, spacing: CGFloat(preference.lineSpacing)) {
                        ForEach(exampleLines, id: \.self) { _ in
                            Divider()
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                Spacer()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                IconButton(icon: "gobackward") {
                    preference.resetFont()
                }
            }
        }

    }
}
