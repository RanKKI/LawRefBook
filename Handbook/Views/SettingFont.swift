import SwiftUI

private let exampleLines = [
    "第二百一十四条 不动产物权的设立、变更、转让和消灭，依照法律规定应当登记的，自记载于不动产登记簿时发生效力。",
    "第二百一十五条 当事人之间订立有关设立、变更、转让和消灭不动产物权的合同，除法律另有规定或者当事人另有约定外，自合同成立时生效；未办理物权登记的，不影响合同效力。",
    "第二百一十六条 不动产登记簿是物权归属和内容的根据。",
]

private struct AdjustSteppter: View {
    
    var title: String
    @Binding var value: Int

    var body: some View {
        Group {
            Divider()
            Stepper {
                Text("\(title): \(value)")
            } onIncrement: {
                value += 1
            } onDecrement: {
                value = max(1, value - 1)
            }
            Divider()
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8))
    }
}

struct FontSettingView: View {

    @AppStorage("font_content")
    var contentFontSize: Int = 17

    var body: some View {

        VStack(alignment: .leading) {
            AdjustSteppter(title: "正文", value: $contentFontSize)
            Group {
                LawContentTitleView(text: "中华人民共和国民法典")
                LawContentTitleView(text: "物权编")
                LawContentHeaderView(text: "第一分编  通则", indent: 1)
                LawContentHeaderView(text: "第一章  一般规定", indent: 2)
                Divider()
                ForEach(exampleLines, id: \.self) { text in
                    LawContentLineView(text: text)
                        .font(.system(size: CGFloat(contentFontSize)))
                    Divider()
                }
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))

            Spacer()
        }

    }
}
