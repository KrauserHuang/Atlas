//
//  MapTab.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/22.
//

import MapKit
import SwiftUI

enum MapOptions: String, Identifiable, CaseIterable {
    case standard
    case hybrid
    case imagery
    
    var id: String { rawValue }
    
    var mapStyle: MapStyle {
        switch self {
        case .standard: return .standard
        case .hybrid: return .hybrid
        case .imagery: return .imagery
        }
    }
}

struct MapTab: View {
    
    @State private var locationManager = LocationManager.shared
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var isSheetPresented: Bool = true
    @State private var query: String = ""
    @State private var isSearching: Bool = false
    // 搜尋結果，MKMapItem vs SearchResult
    @State private var mapItems: [MKMapItem] = []
    @State private var selectedMapItem: MKMapItem?
    @State private var searchResults: [SearchResult] = []
    @State private var selectedLocation: SearchResult?
    @State private var scene: MKLookAroundScene?
    // 地圖範圍命名空間，用於控制地圖相關的 UI 元件
    @Namespace var mapScope
    
    var body: some View {
        ZStack {
//            Map(position: $position, selection: $selectedMapItem, scope: mapScope) {
////                ForEach(mapItems, id: \.self) { mapItem in
////                    Marker(item: mapItem)
////                }
////                Marker("Taipei 101", coordinate: .taipei101)
//                Annotation("Taipei 101", coordinate: .taipei101, anchor: .bottom) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(.background)
//                        Image(systemName: "house")
//                            .padding(5)
//                    }
//                }
//                UserAnnotation()
//            }
//            .mapControlVisibility(.hidden)
//            .mapStyle(.standard(elevation: .realistic))
//            .onChange(of: locationManager.region) {
//                withAnimation {
//                    position = .region(locationManager.region)
//                }
//            }
//            .onMapCameraChange { context in
//                visibleRegion = context.region
//            }
//            .overlay(alignment: .topTrailing) {
//                VStack {
//                    Spacer()
//                    MapUserLocationButton(scope: mapScope)
//                    MapPitchToggle(scope: mapScope)
//                    MapCompass(scope: mapScope)
//                        .mapControlVisibility(.visible)
//                    Spacer()
//                }
//                .padding(.trailing, 10)
//                .buttonBorderShape(.roundedRectangle)
//            }
//            .mapScope(mapScope)
//            .sheet(isPresented: $isSheetPresented) {
//                SearchSheetView(query: $query, isSearching: $isSearching, searchResults: $searchResults)
//            }
            
            Map(position: $position, selection: $selectedLocation) {
                ForEach(searchResults) { result in
                    Marker(result.name, coordinate: result.location)
                        .tag(result)
                }
            }
            .overlay(alignment: .bottom) {
                if selectedLocation != nil {
                    LookAroundPreview(scene: $scene, allowsNavigation: false, badgePosition: .bottomTrailing)
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .safeAreaPadding(.bottom, 40)
                        .padding(.horizontal, 20)
                }
            }
            .ignoresSafeArea()
            .onChange(of: selectedLocation) {
                if let selectedLocation {
                    Task {
                        scene = try? await fetchScene(for: selectedLocation.location)
                    }
                }
                // 沒有選中位置，則顯示搜尋面板
                isSheetPresented = selectedLocation == nil
            }
            .onChange(of: searchResults) {
                // 如果只有一個搜尋結果，則自動選中
                if let firstResult = searchResults.first, searchResults.count == 1 {
                    selectedLocation = firstResult
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                SearchSheetView(query: $query, isSearching: $isSearching, searchResults: $searchResults)
            }
        }
    }
    
    private func fetchScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let lookAroundScene = MKLookAroundSceneRequest(coordinate: coordinate)
        return try await lookAroundScene.scene
    }
}

//#Preview {
//    MapTab()
//}
