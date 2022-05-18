import Foundation
import SwiftUI

struct LawInfoPage: View {
    
    var lawID: UUID
    var toc: [LawInfo]
    
    
    @State
    private var laws: [TLaw] = []
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            ForEach(toc, id: \.id) { info in
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
            if !laws.isEmpty {
                Section(header: Text("相关法律法规")) {
                    ForEach(laws) { law in
                        NaviLawLink(law: law)
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
        .task {
            LawDatabase.shared.queue.async {
                let laws = LawDatabase.shared.getRelvantLaws(uuid: self.lawID)
                DispatchQueue.main.async {
                    self.laws =  laws
                }
            }
        }
    }
}
