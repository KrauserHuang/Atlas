//
//  AuthenticationViewModel.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import Foundation
import FirebaseAuth
import SwiftUI
import AuthenticationServices
import CryptoKit
// TODO: 加入 Google Sign-In 依賴後取消註解
// import GoogleSignIn

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

// MARK: - Password Strength Enum
enum PasswordStrength: String {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
    
    var progress: Double {
        switch self {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
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
    
    // Apple Sign-In 所需的 nonce
    private var currentNonce: String?
    
    init() {
        registerAuthStateHandler()
        
        // 判斷isValid狀態，根據flow是否為登入，判斷方式有變化
        // login看email/password
        // signUp看email/password/confirmPassword 以及其他驗證
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                if flow == .login {
                    return !(email.isEmpty || password.isEmpty)
                } else {
                    // SignUp 需要更嚴格的驗證
                    return !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty) &&
                           self.isValidEmail(email) &&
                           password == confirmPassword &&
                           self.getPasswordStrength(password) != .weak
                }
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
    
    func clearErrorMessage() {
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
    
    // MARK: - Validation helpers
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
        let hasSpecialChars = password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]", options: .regularExpression) != nil
        
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

// MARK: - Google Sign-In
extension AuthenticationViewModel {
    func signInWithGoogle() async -> Bool {
        authenticationState = .authenticating
        
        // TODO: 實作 Google Sign-In 邏輯
        // 需要先加入 GoogleSignIn SDK 依賴
        errorMessage = "Google Sign-In implementation pending - need to add GoogleSignIn SDK"
        authenticationState = .unauthenticated
        return false
        
        /* 實作參考 (需要加入 GoogleSignIn SDK 後啟用):
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase client ID not found"
            authenticationState = .unauthenticated
            return false
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        guard let presentingViewController = await UIApplication.shared.windows.first?.rootViewController else {
            errorMessage = "No presenting view controller found"
            authenticationState = .unauthenticated
            return false
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token"
                authenticationState = .unauthenticated
                return false
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            try await Auth.auth().signIn(with: credential)
            return true
        } catch {
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
        */
    }
}

// MARK: - Apple Sign-In
extension AuthenticationViewModel {
    func signInWithApple() async -> Bool {
        authenticationState = .authenticating
        
        do {
            let nonce = randomNonceString()
            currentNonce = nonce
            let hashedNonce = sha256(nonce)
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            // 使用 continuation 來處理回調
            return await withCheckedContinuation { continuation in
                let delegate = AppleSignInDelegate(
                    currentNonce: nonce,
                    onSuccess: { [weak self] in
                        self?.authenticationState = .authenticated
                        continuation.resume(returning: true)
                    },
                    onFailure: { [weak self] error in
                        self?.errorMessage = error.localizedDescription
                        self?.authenticationState = .unauthenticated
                        continuation.resume(returning: false)
                    }
                )
                
                authorizationController.delegate = delegate
                authorizationController.presentationContextProvider = delegate
                authorizationController.performRequests()
                
                // 保持 delegate 的強引用
                objc_setAssociatedObject(
                    authorizationController,
                    &AssociatedKeys.delegateKey,
                    delegate,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        } catch {
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    // 生成隨機 nonce 字符串
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \\(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // SHA256 雜湊
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - Apple Sign-In Delegate
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let currentNonce: String
    private let onSuccess: () -> Void
    private let onFailure: (Error) -> Void
    
    init(currentNonce: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error) -> Void) {
        self.currentNonce = currentNonce
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            onFailure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve Apple ID credential"]))
            return
        }
        
        guard let nonce = currentNonce else {
            onFailure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."]))
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            onFailure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"]))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            onFailure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"]))
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        Task {
            do {
                try await Auth.auth().signIn(with: credential)
                DispatchQueue.main.async {
                    self.onSuccess()
                }
            } catch {
                DispatchQueue.main.async {
                    self.onFailure(error)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onFailure(error)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}

// MARK: - Associated Object Key
private struct AssociatedKeys {
    static var delegateKey: UInt8 = 0
}
