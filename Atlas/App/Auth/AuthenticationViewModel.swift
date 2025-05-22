//
//  AuthenticationViewModel.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import Foundation
import FirebaseAuth

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var flow: AuthenticationFlow = .login
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var isValid: Bool = false
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var displayName: String = ""
    // 儲存Firebase Authentication State參數
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        registerAuthStateHandler()
        
        // 判斷isValid狀態，根據flow是否為登入，判斷方式有變化
        // login看email/password
        // signUp看email/password/confirmPassword
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    // 註冊監聽auth的state變化，當有變化判斷authenticationState並指派user/displayName
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener{ auth, user in
                // 當user sign in，user會有值，反之(sign out)則變成nil
                // 透過user的狀態來改變authenticationState
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.email ?? "(unknown)"
            }
        }
    }
    
    // 變更auth流程，當flow == .login則轉變成.signUp，反之亦然
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(for: .seconds(1))
            print("Done")
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    }
}

// MARK: - Sign in with Email/Password
extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            return true
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            return true
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        } catch {
            print(error)
            errorMessage = error.localizedDescription
            return false
        }
    }
}
