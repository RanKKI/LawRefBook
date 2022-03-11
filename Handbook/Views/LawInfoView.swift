import Foundation
import SwiftUI

struct LawInfoPage: View {

    var lawID: UUID

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List(LawProvider.shared.getLawInfo(lawID), id: \.id){ info in
            if info.header.isEmpty {
                if let text = try? AttributedString(markdown: info.content) {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .listRowSeparator(.hidden)
                        .textSelection(.enabled)
                }
            }else{
                Section(header: Text(info.header)){
                    Text(info.content)
                        .textSelection(.enabled)
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
