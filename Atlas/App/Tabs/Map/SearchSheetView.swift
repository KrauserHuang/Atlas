//
//  SearchSheetView.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/27.
//

import MapKit
import SwiftUI

struct SearchSheetView: View {
    @Binding var query: String
    @Binding var isSearching: Bool
    @Binding var searchResults: [SearchResult]
    @Binding var selectedLocation: SearchResult?
    
    private let locationManager = LocationManager.shared
    
    var body: some View {
        VStack {
            SearchBarView(searchText: $query, isSearching: $isSearching)
                .onSubmit {
                    Task {
                        do {
                            let results = try await locationManager.performSearch(with: query)
                            await MainActor.run {
                                searchResults = results
                            }
                        } catch {
                            print("Search failed: \(error)")
                        }
                    }
                }
            
            Spacer()
            
            List {
                ForEach(locationManager.completions) { completion in
                    Button(action: { didTapOnCompletion(completion) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .fontDesign(.rounded)
                            
                            Text(completion.subTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if let url = completion.url {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text(url.absoluteString)
                                    }
                                    .font(.caption)
                                    .lineLimit(1)
                                    .foregroundStyle(.blue)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)   // 隱藏列表背景
        }
        .onChange(of: query) { _, newQuery in
            // 當搜尋文字 query 改變，觸發自動更新建議
            locationManager.query = newQuery
            locationManager.updateSearchCompletions(queryFragment: newQuery)
        }
        .padding()
        .interactiveDismissDisabled()                   // 禁止用手勢關閉列表
        .presentationDetents([.height(200), .large])    // 列表面板高度設定：高度200/大尺寸
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large)) // 允許背景互動
    }
    
    /// 處理用戶點擊搜尋建議項目
    /// - Parameter completion: 被點擊的搜尋建議項目
    private func didTapOnCompletion(_ completion: SearchCompletion) {
        Task {
            do {
                let singleResults = try await locationManager.searchFromCompletion(completion)
                if let first = singleResults.first {
                    await MainActor.run {
                        selectedLocation = first
                    }
                }
                
                await MainActor.run {
                    searchResults = singleResults
                }
                
            } catch {
                print("SearchFromCompletion 失敗：\(error)")
            }
        }
    }
}

//#Preview("SearchSheetView", traits: .sizeThatFitsLayout) {
//    SearchSheetView(query: .constant("1"), isSearching: .constant(true))
//}
