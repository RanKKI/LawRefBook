import SwiftUI


@main
struct MainApp: App {

    @State var showNewPage = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, LawProvider.shared.container.viewContext)
                .sheet(isPresented: $showNewPage) {
                    WhatNewView()
                }
                .onAppear {
                    self.checkVersionUpdate()
                    LawProvider.shared.loadLawList()
                }
        }
    }

    private func checkVersionUpdate(){
        let lastVersion = UserDefaults.standard.string(forKey: "lastVersion")
        let curVersion = UIApplication.appVersion
        if lastVersion == nil || lastVersion != curVersion {
            showNewPage.toggle()
            UserDefaults.standard.set(curVersion, forKey: "lastVersion")
        }
    }

}
