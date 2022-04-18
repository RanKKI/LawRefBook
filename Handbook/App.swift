import SwiftUI
import CoreSpotlight
import CoreData

@main
struct MainApp: App {

    @State
    var showNewPage = false

    @AppStorage("lastVersion")
    var lastVersion: String?

    @AppStorage("launchTimes")
    var launchTime: Int = 0
    
    private(set) var moc = LawProvider.shared.container.viewContext

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                WelcomeView()
            }
            .sheet(isPresented: $showNewPage) {
                WhatNewView()
            }
            .environment(\.managedObjectContext, moc)
            .phoneOnlyStackNavigationView()
            .task {
                self.checkVersionUpdate()
            }
        }
    }

    private func checkVersionUpdate(){
        let curVersion = UIApplication.appVersion
        if lastVersion == nil || lastVersion != curVersion {
            // showNewPage.toggle()
            lastVersion = curVersion
        }
    }

    private func checkRunTimes(){
        if launchTime == 4 {
            AppStoreReviewManager.requestReviewIfAppropriate()
        }
        launchTime += 1;
    }

}
