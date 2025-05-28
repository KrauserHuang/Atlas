//
//  SearchBarView.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/27.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search a location...", text: $searchText)
                .keyboardType(.asciiCapable)        // 設定鍵盤類型為 ASCII 字符
                .autocorrectionDisabled()           // 關閉自動校正功能
                .overlay(alignment: .trailing) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(searchText.isEmpty ? .clear : .secondary)
                        .onTapGesture {
                            searchText = ""
                        }
                }
                .onSubmit {
                    isSearching = true
                }
        }
        .font(.headline)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(.background)
                .shadow(color: .secondary.opacity(0.2), radius: 10, x: 0, y: 0)
        }
    }
}

//#Preview("SearchBarView", traits: .sizeThatFitsLayout) {
//    SearchBarView(searchText: .constant("1"), isSearching: .constant(true))
//}
