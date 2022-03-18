import Foundation
import SwiftUI

struct LawInfoPage: View {

    var lawID: UUID

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List{
            ForEach(LawProvider.shared.getLawInfo(lawID), id: \.id) { info in
                if !info.header.isEmpty {
                    Section(header: Text(info.header)){
                        Text(info.content)
                            .textSelection(.enabled)
                    }
                } else if let text = try? AttributedString(markdown: info.content) {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                }
            }
            if let law = LocalProvider.shared.getLaw(lawID) {
                if let arr = law.links {
                    Section(header: Text("相关法律法规")) {
                        ForEach(arr, id: \.self) { uid in
                            NaviLawLink(uuid: uid)
                        }
                    }
                }
            }

        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                CloseSheetItem() {
                    dismiss()
                }
            }
        }
    }
}
