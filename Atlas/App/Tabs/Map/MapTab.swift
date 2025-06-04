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
    @State private var query: String = ""
    @State private var isSearching: Bool = false
    // 搜尋結果，SearchResult
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
//                        .tag(MapSelection(result.mapItem))
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
            .onChange(of: selectedLocation) { _, newSelection in
                if let selected = newSelection {
                    let coord = selected.mapItem.placemark.coordinate
                    
                    withAnimation {
                        position = .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                    }
                    
                    Task {
                        scene = try? await fetchScene(for: coord)
                    }
                }
                // 沒有選中位置，則顯示搜尋面板
                isSearching = false
                printPlacemarkInfo()
            }
            .onChange(of: searchResults) {
                // 如果只有一個搜尋結果，則自動選中
                if let firstResult = searchResults.first, searchResults.count == 1 {
                    selectedLocation = firstResult
                }
            }
            .sheet(isPresented: $isSearching) {
                SearchSheetView(
                    query: $query,
                    isSearching: $isSearching,
                    searchResults: $searchResults,
                    selectedLocation: $selectedLocation
                )
            }
            .mapItemDetailSheet(item: selectedMapItemBinding)
            
            VStack {
                SearchBarView(searchText: $query, isSearching: $isSearching)
                    .onTapGesture {
                        isSearching = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                Spacer()
            }
        }
    }
    
    /// 取得指定座標 Look Around 街景場景
    /// - Parameter coordinate: 目標位置座標
    /// - Returns: 街景場景實例
    private func fetchScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let lookAroundScene = MKLookAroundSceneRequest(coordinate: coordinate)
        return try await lookAroundScene.scene
    }
    
    private func printPlacemarkInfo() {
        guard let placemark = selectedLocation?.mapItem.placemark else { return }
        
        // Print all available placemark information
        print("=== Placemark Information ===")
        print("Name: \(placemark.name ?? "N/A")")
        print("Title: \(placemark.title ?? "N/A")")
        print("Thoroughfare (Street): \(placemark.thoroughfare ?? "N/A")")
        print("SubThoroughfare (Street Number): \(placemark.subThoroughfare ?? "N/A")")
        print("Locality (City): \(placemark.locality ?? "N/A")")
        print("SubLocality: \(placemark.subLocality ?? "N/A")")
        print("Administrative Area (State): \(placemark.administrativeArea ?? "N/A")")
        print("SubAdministrative Area: \(placemark.subAdministrativeArea ?? "N/A")")
        print("Postal Code: \(placemark.postalCode ?? "N/A")")
        print("Country: \(placemark.country ?? "N/A")")
        print("ISO Country Code: \(placemark.isoCountryCode ?? "N/A")")
        print("Location: \(placemark.location?.coordinate.latitude ?? 0), \(placemark.location?.coordinate.longitude ?? 0)")
        
        // Print MKMapItem specific information
        print("\n=== MapItem Information ===")
        print("Phone Number: \(selectedLocation?.mapItem.phoneNumber ?? "N/A")")
        print("URL: \(selectedLocation?.mapItem.url?.absoluteString ?? "N/A")")
        print("Point of Interest Category: \(selectedLocation?.mapItem.pointOfInterestCategory?.rawValue ?? "N/A")")
        //        if let hours = selectedItem?.openingHours {
        //            print("Opening Hours: \(hours)")
        //        }
    }
}

//#Preview {
//    MapTab()
//}
