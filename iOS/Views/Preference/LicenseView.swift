import SwiftUI

struct LicenseView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                Text(LocalProvider.shared.ANIT996_LICENSE)
            }
            .padding()
        }
        .navigationTitle("LICENSE")
    }

}
