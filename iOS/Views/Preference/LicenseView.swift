import SwiftUI

struct LicenseView: View {
    
    private var LICENSE: String? {
        LocalManager.shared.ANIT996_LICENSE
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                Text(LICENSE ?? "NO CONTENT")
            }
            .padding()
        }
        .navigationTitle("LICENSE")
    }

}
