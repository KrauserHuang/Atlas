//
//  AtlasApp.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI
import FirebaseCore
import MapKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Tab Views

struct MapTabView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        Map(coordinateRegion: $region)
            .edgesIgnoringSafeArea(.all)
            .tabItem {
                Label("Map", systemImage: "map")
            }
    }
}

struct ListTabView: View {
    var body: some View {
        NavigationView {
            List(1...20, id: \.self) { item in
                Text("Item \(item)")
            }
            .navigationTitle("List")
        }
        .tabItem {
            Label("List", systemImage: "list.bullet")
        }
    }
}

struct MemberTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text("Member Profile")
                    .font(.title)
                // Add more member-related views here
            }
            .navigationTitle("Member")
        }
        .tabItem {
            Label("Member", systemImage: "person")
        }
    }
}

@main
struct AtlasApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MapTabView()
                ListTabView()
                MemberTabView()
//                AuthenticatedView {
//                    Text("HI")
//                }
//                .environmentObject(authViewModel)
            }
//            .onAppear {
//                // Make tab bar non-transparent
//                let appearance = UITabBarAppearance()
//                appearance.configureWithOpaqueBackground()
//                appearance.backgroundColor = UIColor.systemBackground
//                UITabBar.appearance().standardAppearance = appearance
//                UITabBar.appearance().scrollEdgeAppearance = appearance
//            }
        }
    }
}
