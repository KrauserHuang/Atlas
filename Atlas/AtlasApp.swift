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
    @State var searchText: String = ""

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Map", systemImage: "map") {
                    MapTab()
                }
                
                Tab("List", systemImage: "list.bullet") {
                    ListTab()
                }
                
                Tab("Profile", systemImage: "person") {
                    ProfileTab()
                }
                
                Tab(role: .search) {
                    NavigationStack {
                        SearchTab(searchText: $searchText)
                    }
                    .searchable(text: $searchText, prompt: "Search locations")
                }
            }
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
