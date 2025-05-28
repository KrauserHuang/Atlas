//
//  SearchSheetView.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/27.
//

import MapKit
import SwiftUI

struct SearchSheetView: View {
    
    @State private var locationService = LocationService(completer: .init())
    @Binding var query: String
    @Binding var isSearching: Bool
    @Binding var searchResults: [SearchResult]
    
    var body: some View {
        VStack {
            SearchBarView(searchText: $query, isSearching: $isSearching)
                .onSubmit {
                    Task {
                        searchResults = try await locationService.search(with: query)
                    }
                }
            
            Spacer()
            
            List {
                ForEach(locationService.completions) { completion in
                    Button(action: { didTapOnCompletion(completion) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text(completion.subTitle)
                            
                            if let url = completion.url {
                                Link(url.absoluteString, destination: url)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)   // 隱藏列表背景
        }
        .onChange(of: query) {
            // 當搜尋文字 query 改變，觸發自動更新建議
            locationService.update(queryFragment: query)
        }
        .padding()
        .interactiveDismissDisabled()                   // 禁止用手勢關閉列表
        .presentationDetents([.height(200), .large])    // 列表面板高度設定：高度200/大尺寸
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large)) // 允許背景互動
    }
    
    /// 處理用戶點擊搜尋建議項目
    /// - Parameter completion: 被點擊的搜尋建議項目
    private func didTapOnCompletion(_ completion: SearchCompletions) {
        Task {
            if let singleLocation = try? await locationService.search(with: "\(completion.title) \(completion.subTitle)").first {
                searchResults = [singleLocation]
            }
        }
    }
}

//#Preview("SearchSheetView", traits: .sizeThatFitsLayout) {
//    SearchSheetView(query: .constant("1"), isSearching: .constant(true))
//}
