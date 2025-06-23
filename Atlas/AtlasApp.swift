//
//  AtlasApp.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct AtlasApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthenticationViewModel()
    @State var selectedTab: AppTab = .map
    
    var body: some Scene {
        WindowGroup {
//            Group {
//                switch authViewModel.authenticationState {
//                case .authenticated:
//                    mainTabView
//                case .authenticating:
//                    ProgressView()
//                default:
//                    AuthenticationView()
//                        .environmentObject(authViewModel)
//                }
//            }
            NavigationView {
                AuthenticatedView {
                    VStack {
                        Image(systemName: "number.circle.fill")
                            .resizable()
                            .frame(width: 100 , height: 100)
                            .foregroundColor(Color(.systemPink))
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .clipped()
                            .padding(4)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        Text("Welcome to Favourites!")
                            .font(.title)
                        Text("You need to be logged in to use this app.")
                        mainTabView
                        Spacer()
                    }
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
