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
    
    var body: some View {
        VStack {
            SearchBarView(searchText: $query, isSearching: $isSearching)
            
            Spacer()
            
            List {
                ForEach(locationService.completions) { completion in
                    Button(action: {}) {
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
            .scrollContentBackground(.hidden)
        }
        .onChange(of: query) {
            locationService.update(queryFragment: query)
        }
        .padding()
        .interactiveDismissDisabled()
        .presentationDetents([.height(200), .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
    }
}

//#Preview("SearchSheetView", traits: .sizeThatFitsLayout) {
//    SearchSheetView(query: .constant("1"), isSearching: .constant(true))
//}
