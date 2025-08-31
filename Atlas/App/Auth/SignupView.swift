//
//  SignupView.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/7/12.
//

import SwiftUI

// MARK: - Signup View
struct SignupView: View {
    @EnvironmentObject private var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var focusedField: Field?
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var agreedToTerms = false
    
    private enum Field: Hashable {
        case email, password, confirmPassword
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
                    confirmPasswordField
                    termsAgreementSection
                    signUpButton
                    
                    // Error message display
                    if !viewModel.errorMessage.isEmpty {
                        errorMessageView
                    }
                }
                
                // Divider
                dividerView
                
                // Social Login
                socialLoginSection
                
                // Navigate to Login
                navigationToLogin
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
extension SignupView {
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Create Account 🚀")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Join us to discover amazing food experiences near you")
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
                    .onChange(of: viewModel.email) { _, _ in
                        viewModel.clearErrorMessage()
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            
            // Email validation feedback
            if !viewModel.email.isEmpty && !isValidEmail(viewModel.email) {
                Text("Please enter a valid email address")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
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
                
                ZStack {
                    SecureField("Enter your password", text: $viewModel.password)
                        .opacity(isPasswordVisible ? 0 : 1)
                    
                    TextField("Enter your password", text: $viewModel.password)
                        .opacity(isPasswordVisible ? 1 : 0)
                }
                .textContentType(.newPassword)
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }
                
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
            
            // Password strength indicator
            if !viewModel.password.isEmpty {
                passwordStrengthIndicator
            }
        }
    }
    
    private var confirmPasswordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confirm Password")
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                
                ZStack {
                    SecureField("Confirm your password", text: $viewModel.confirmPassword)
                        .opacity(isConfirmPasswordVisible ? 0 : 1)
                    
                    TextField("Confirm your password", text: $viewModel.confirmPassword)
                        .opacity(isConfirmPasswordVisible ? 1 : 0)
                }
                .textContentType(.newPassword)
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit { focusedField = nil }
                
                Button(action: {
                    isConfirmPasswordVisible.toggle()
                }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            
            // Password match validation
            if !viewModel.confirmPassword.isEmpty && !passwordsMatch {
                Text("Passwords do not match")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
    
    private var passwordStrengthIndicator: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Password Strength:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(passwordStrength.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(passwordStrength.color)
            }
            
            ProgressView(value: passwordStrength.progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: passwordStrength.color))
                .frame(height: 4)
        }
    }
    
    private var termsAgreementSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                agreedToTerms.toggle()
            }) {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .foregroundStyle(agreedToTerms ? .blue : .secondary)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("I agree to the Terms of Service and Privacy Policy")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 16) {
                    Button("Terms of Service") {
                        // TODO: Show terms of service
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                    
                    Button("Privacy Policy") {
                        // TODO: Show privacy policy
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
            }
            
            Spacer()
        }
    }
    
    private var signUpButton: some View {
        Button(action: signUpWithEmailPassword) {
            HStack {
                if viewModel.authenticationState == .authenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isSignUpButtonEnabled ? Color.blue : Color.gray.opacity(0.6))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: isSignUpButtonEnabled ? .blue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
        }
        .padding(.top, 8)
        .disabled(!isSignUpButtonEnabled)
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
            Button(action: signUpWithGoogle) {
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
            Button(action: signUpWithApple) {
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
    
    private var navigationToLogin: some View {
        HStack {
            Text("Already have an account?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Sign In") {
                viewModel.switchFlow()
            }
            .font(.subheadline.bold())
            .foregroundStyle(.blue)
        }
        .padding(.top, 16)
    }
    
    private var errorMessageView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.red)
            
            Text(viewModel.errorMessage)
                .font(.caption)
                .foregroundStyle(.red)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
        )
    }
}

// MARK: - Helper Properties
extension SignupView {
    private var isSignUpButtonEnabled: Bool {
        !viewModel.email.isEmpty &&
        !viewModel.password.isEmpty &&
        !viewModel.confirmPassword.isEmpty &&
        isValidEmail(viewModel.email) &&
        passwordsMatch &&
        passwordStrength != .weak &&
        agreedToTerms &&
        viewModel.authenticationState != .authenticating
    }
    
    private var passwordsMatch: Bool {
        viewModel.password == viewModel.confirmPassword
    }
    
    private var passwordStrength: PasswordStrength {
        getPasswordStrength(viewModel.password)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func getPasswordStrength(_ password: String) -> PasswordStrength {
        let length = password.count
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumbers = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChars = password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\\"|,.<>\\/?]", options: .regularExpression) != nil
        
        var score = 0
        if length >= 8 { score += 1 }
        if hasUppercase { score += 1 }
        if hasLowercase { score += 1 }
        if hasNumbers { score += 1 }
        if hasSpecialChars { score += 1 }
        
        switch score {
        case 0...2: return .weak
        case 3...4: return .medium
        case 5: return .strong
        default: return .weak
        }
    }
}

// MARK: - Actions
extension SignupView {
    private func signUpWithEmailPassword() {
        guard viewModel.authenticationState != .authenticating else { return }
        
        Task {
            await viewModel.signUpWithEmailPassword()
        }
    }
    
    private func signUpWithGoogle() {
        guard viewModel.authenticationState != .authenticating else { return }
        
        Task {
            await viewModel.signInWithGoogle()
        }
    }
    
    private func signUpWithApple() {
        guard viewModel.authenticationState != .authenticating else { return }
        
        Task {
            await viewModel.signInWithApple()
        }
    }
}


// MARK: - Preview
#Preview {
    SignupView()
        .environmentObject(AuthenticationViewModel())
        .preferredColorScheme(.light)
}

#Preview {
    SignupView()
        .environmentObject(AuthenticationViewModel())
        .preferredColorScheme(.dark)
}