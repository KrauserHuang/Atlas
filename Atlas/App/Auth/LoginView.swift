//
//  LoginView.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var focusedField: Field?
    @State private var isPasswordVisible = false
    
    private enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Form
                VStack(spacing: 16) {
                    emailField
                    passwordField
                    forgotPasswordButton
                    signInButton
                }
                
                // Divider
                dividerView
                
                // Social Login
                socialLoginSection
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .disabled(viewModel.authenticationState == .authenticating)
        .overlay(
            Group {
                if viewModel.authenticationState == .authenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
        )
    }
}

// MARK: - View Components
extension LoginView {
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Welcome Back! 👋")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Sign in to continue exploring amazing food near you")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email Address")
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            
            HStack {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                
                TextField("Enter your email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            
            HStack {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)
                
                // 使用 ZStack 避免切換時的抖動
                ZStack {
                    SecureField("Enter your password", text: $viewModel.password)
                        .opacity(isPasswordVisible ? 0 : 1)
                    
                    TextField("Enter your password", text: $viewModel.password)
                        .opacity(isPasswordVisible ? 1 : 0)
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    private var forgotPasswordButton: some View {
        Button(action: forgotPassword) {
            Text("Forgot Password?")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(.blue)
        }
    }
    
    private var signInButton: some View {
        Button(action: signInWithEmailPassword) {
            HStack {
                if viewModel.authenticationState == .authenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.top, 8)
        .disabled(!viewModel.isValid)
    }
    
    private var dividerView: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text("OR")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: 12) {
            // Google Button
            Button(action: signInWithGoogle) {
                HStack {
                    Image(.googlelogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Continue with Google")
                        .font(.subheadline.bold())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Apple Button
            Button(action: signInWithApple) {
                HStack {
                    Image(systemName: "applelogo")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .frame(width: 20, height: 20)
                    
                    Text("Continue with Apple")
                        .font(.subheadline.bold())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - Actions
extension LoginView {
    private func forgotPassword() {
        // TODO: Implement forgot password flow
        print("Forgot password tapped")
    }
    
    private func signInWithEmailPassword() {
        guard viewModel.authenticationState != .authenticating else { return }
        
        Task {
            await viewModel.signInWithEmailPassword()
        }
    }
    
    private func signInWithGoogle() {
        // TODO: Implement Google sign in
        print("Sign in with Google tapped")
    }
    
    private func signInWithApple() {
        // TODO: Implement Apple sign in
        print("Sign in with Apple tapped")
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
        .preferredColorScheme(.light)
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
        .preferredColorScheme(.dark)
}
