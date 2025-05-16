//
//  Tabs.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/15.
//

import Foundation

@MainActor
enum AppTab: Int, Identifiable, Hashable, CaseIterable, Codable {
    case map
    case list
    case profile
    
    nonisolated var id: Int {
        rawValue
    }
    
    static func loggedOutTab() -> [AppTab] {
        [.map, .list, .profile]
    }
    
//    @ViewBuilder
//    func makeContentView(selectedTab: Binding<AppTab>) -> some View {
//        switch self {
//        case .map:
//            <#code#>
//        case .list:
//            <#code#>
//        case .profile:
//            <#code#>
//        }
//    }
}
