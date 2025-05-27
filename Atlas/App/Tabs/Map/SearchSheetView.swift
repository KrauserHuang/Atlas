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
    
    var body: some View {
        VStack {
            SearchBarView(searchText: $query, isSearching: $isSearching)
            
            Spacer()
        }
        .padding()
        .interactiveDismissDisabled()
        .presentationDetents([.height(200), .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
    }
}

#Preview("SearchSheetView", traits: .sizeThatFitsLayout) {
    SearchSheetView(query: .constant("1"), isSearching: .constant(true))
}
