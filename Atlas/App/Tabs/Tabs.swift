//
//  Tabs.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/15.
//

import Foundation
import SwiftUI

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
    
    /*
     允許條件返回不同的視圖
     根據不同App Tab顯示不同的視圖
     */
    @ViewBuilder
    func makeContentView(selectedTab: Binding<AppTab>) -> some View {
        switch self {
        case .map:
            MapTab()
        case .list:
            ListTab()
        case .profile:
            ProfileTab()
        }
    }
    
    @ViewBuilder
    var label: some View {
        Label(title, systemImage: iconName)
    }
    
    /*
     LocalizedStringKey → 處理本地化字符串
     會自動在本地化資料查詢對應翻譯
     他只是鍵(Key)，利用這個Key來找尋本地化文件對應的語言文本
     */
    var title: LocalizedStringKey {
        switch self {
        case .map:
            "map"
        case .list:
            "list"
        case .profile:
            "profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .map:
            "map"
        case .list:
            "list.bullet"
        case .profile:
            "person"
        }
    }
}
