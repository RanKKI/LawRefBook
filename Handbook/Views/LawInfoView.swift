import Foundation
import SwiftUI

struct LawInfoPage: View {

    var lawID: UUID

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List(LawProvider.shared.getLawInfo(lawID), id: \.id){ info in
            if info.header.isEmpty {
                Text(info.content)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .listRowSeparator(.hidden)
            }else{
                Section(header: Text(info.header)){
                    Text(info.content)
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
