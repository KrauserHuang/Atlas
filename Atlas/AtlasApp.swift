//
//  AtlasApp.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct AtlasApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var authViewModel = AuthenticationViewModel()
    @State var selectedTab: AppTab = .map
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    tab.makeContentView(selectedTab: $selectedTab)
                        .tabItem {
                            tab.label
                        }
                        .tag(tab)
                }
            }
//            TabView {
//                MapView()
//                ListView()
//                ProfileView()
//                AuthenticatedView {
//                    Text("HI")
//                }
//                .environmentObject(authViewM odel)
//            }
            .onAppear {
                // Make tab bar non-transparent
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.systemBackground
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
