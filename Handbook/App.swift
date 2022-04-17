import SwiftUI
import CoreSpotlight

@main
struct MainApp: App {

    @State var showNewPage = false

    @AppStorage("lastVersion")
    var lastVersion: String?

    @AppStorage("launchTimes")
    var launchTime: Int = 0

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, LawProvider.shared.container.viewContext)
                    .sheet(isPresented: $showNewPage) {
                        WhatNewView()
                    }
                WelcomeView()
            }
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
