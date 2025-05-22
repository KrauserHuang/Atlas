//
//  ProfileView.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/21.
//

import SwiftUI

struct ProfileView: View {
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
    }
}

//#Preview {
//    ProfileView()
//}
