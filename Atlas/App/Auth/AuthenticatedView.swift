//
//  AuthenticatedView.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI

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
    
    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content
    
    public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated
        self.content = content
    }
    
    var body: some View {
        switch viewModel.authenticationState {
        case .unauthenticated, .authenticating:
            AuthenticationView()
                .environmentObject(viewModel)
        case .authenticated:
            Text("You are logged in as \(viewModel.displayName)")
        }
    }
}

#Preview {
    AuthenticatedView {
        Text("You are signed in.")
    }
}
