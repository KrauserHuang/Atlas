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
    // 街景場景
    @State private var scene: MKLookAroundScene?
    // 地圖範圍命名空間，用於控制地圖相關的 UI 元件
    @Namespace var mapScope
    
    // Computed binding to convert SearchResult to MKMapItem
    private var selectedMapItemBinding: Binding<MKMapItem?> {
        Binding(
            get: { selectedLocation?.mapItem },
            set: { newMapItem in
                if let newMapItem = newMapItem {
                    // Find the SearchResult that corresponds to this MKMapItem
                    selectedLocation = searchResults.first { $0.mapItem == newMapItem }
                } else {
                    selectedLocation = nil
                }
            }
        )
    }
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedLocation, scope: mapScope) {
                ForEach(searchResults, id: \.self) { result in
                    // 直接使用MKMapItem創建標記取得更多資訊
                    Marker(item: result.mapItem)
                        .tag(result)
                }
                UserAnnotation()
            }
            .mapControlVisibility(.hidden)              // 隱藏預設地圖控制選項
            .mapStyle(.standard(elevation: .realistic))
            .onChange(of: locationManager.region) {
                // 當locationManager區域變動，更新相機
                withAnimation {
                    position = .region(locationManager.region)
                }
            }
            .onMapCameraChange { context in
                // 相機變化監聽，更新可見區域，用於追蹤使用者當前查看的地圖範圍
                visibleRegion = context.region
            }
            .overlay(alignment: .topTrailing) {
                VStack {
                    Spacer()
                    MapUserLocationButton(scope: mapScope)  // 定位使用者位置按鈕
                    MapPitchToggle(scope: mapScope)         // 2D/3D切換
                    MapCompass(scope: mapScope)             // 指南針
                        .mapControlVisibility(.visible)
                    Spacer()
                }
                .padding(.trailing, 10)
                .buttonBorderShape(.roundedRectangle)
            }
            .mapScope(mapScope)
//            .overlay(alignment: .bottom) {
//                if selectedLocation != nil {
//                    LookAroundPreview(scene: $scene, allowsNavigation: true, badgePosition: .bottomTrailing)
//                        .frame(height: 150)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .safeAreaPadding(.bottom, 40)
//                        .padding(.horizontal, 20)
//                }
//            }
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
            .mapItemDetailSheet(item: selectedMapItemBinding)
        }
    }
    
    /// 取得指定座標 Look Around 街景場景
    /// - Parameter coordinate: 目標位置座標
    /// - Returns: 街景場景實例
    private func fetchScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let lookAroundScene = MKLookAroundSceneRequest(coordinate: coordinate)
        return try await lookAroundScene.scene
    }
}

//#Preview {
//    MapTab()
//}
