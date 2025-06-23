//
//  AuthenticatedView.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI
import AuthenticationServices

extension AuthenticatedView where Unauthenticated == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
//    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var presentingLoginScreen: Bool = false
    @State private var presentingMainScreen: Bool = false
    @State var selectedTab: AppTab = .map
    
    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content
    
    public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated
        self.content = content
    }
    
//    var body: some View {
//        switch viewModel.authenticationState {
//        case .unauthenticated, .authenticating:
//            AuthenticationView()
//                .environmentObject(viewModel)
//        case .authenticated:
//            Text("You are logged in as \(viewModel.displayName)")
//        }
//    }
    
    var body: some View {
        switch viewModel.authenticationState {
        case .unauthenticated, .authenticating:
            VStack {
                if let unauthenticated = unauthenticated {
                    unauthenticated
                }
                else {
                    Text("You're not logged in.")
                }
                Button("Tap here to log in") {
                    viewModel.reset()
                    presentingLoginScreen.toggle()
                }
            }
            .sheet(isPresented: $presentingLoginScreen) {
                AuthenticationView()
                    .environmentObject(viewModel)
            }
        case .authenticated:
            VStack {
                content()
                Text("You're logged in as \(viewModel.displayName).")
                Button("Tap here to view your profile") {
                    presentingMainScreen.toggle()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
                viewModel.signOut()
                if let userInfo = event.userInfo, let info = userInfo["info"] {
                    print(info)
                }
            }
            .sheet(isPresented: $presentingMainScreen) {
                NavigationView {
                    mainTabView
                        .environmentObject(viewModel)
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

#Preview {
    AuthenticatedView {
        Text("You are signed in.")
    }
}
