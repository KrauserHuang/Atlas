//
//  AuthenticationView.swift
//  Atlas
//
//  Created by Tai Chin Huang on 2025/4/5.
//

import SwiftUI

struct AuthenticationView: View {
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        switch viewModel.flow {
        case .login:
            LoginView()
                .environmentObject(viewModel)
        case .signUp:
            LoginView()
                .environmentObject(viewModel)
        }
    }
}

//#Preview {
//    AuthenticationView()
//        .environmentObject(AuthenticationViewModel())
//}
