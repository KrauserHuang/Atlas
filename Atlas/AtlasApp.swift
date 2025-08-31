//
//  AtlasApp.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
// TODO: 加入 GoogleSignIn SDK 依賴後取消註解
// import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // TODO: 加入 GoogleSignIn SDK 依賴後取消註解
        // Configure Google Sign-In
        // guard let clientID = FirebaseApp.app()?.options.clientID else {
        //     fatalError("Firebase client ID not found")
        // }
        // GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        return true
    }
    
    // TODO: 加入 GoogleSignIn SDK 依賴後取消註解
    // Handle URL scheme for Google Sign-In
    // func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    //     return GIDSignIn.sharedInstance.handle(url)
    // }
}

@main
struct AtlasApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthenticationViewModel()
    @State var selectedTab: AppTab = .map
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch authViewModel.authenticationState {
                case .authenticated:
                    mainTabView
                case .authenticating:
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                default:
                    AuthenticationView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tab.makeContentView(selectedTab: $selectedTab)
                    .tabItem {
                        tab.label
                    }
                    .tag(tab)
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
