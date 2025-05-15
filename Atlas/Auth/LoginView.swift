//
//  LoginView.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI

private enum FocusedField: Hashable {
    case email, password
}

struct LoginView: View {
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusedField?
    
    var body: some View {
        VStack {
            // Header
            Text("Sign in with your account 🚀")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity)
            // Subtitle
            Text("Welcome to Atlas, where you can discover the amazing food here")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            // Email
            Text("Email")
                .font(.system(size: 16))
            TextField("Email", text: $viewModel.email)
                .focused($focus, equals: .email)
            // Password
            Text("Password")
                .font(.system(size: 16))
            SecureField("Password", text: $viewModel.password)
                .focused($focus, equals: .password)
            // Forgot password button
            Button(action: forgotPassword) {
                Text("Forgot Password?")
            }
            // OR divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary)
                
                Text("OR")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary)
            }
            // Login button
            Button(action: signInWithEmailPassword) {
                Text("Login")
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .foregroundStyle(.white)
                    .background(.blue)
            }
            .buttonStyle(.borderedProminent)
        }
        .listStyle(.plain)
        .padding()
    }
}

// MARK: - Action
extension LoginView {
    private func forgotPassword() {
        print("Under Construction!")
    }
    
    private func signInWithEmailPassword() {
        Task {
            if await viewModel.signInWithEmailPassword() {
                print("Login Success")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
