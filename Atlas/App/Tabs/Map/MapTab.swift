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
    @State private var mapItems: [MKMapItem] = []
    @State private var selectedMapItem: MKMapItem?
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var isSheetPresented: Bool = true
    @State private var query: String = ""
    @State private var isSearching: Bool = false
    
    @Namespace var mapScope
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedMapItem, scope: mapScope) {
//                ForEach(mapItems, id: \.self) { mapItem in
//                    Marker(item: mapItem)
//                }
//                Marker("Taipei 101", coordinate: .taipei101)
                Annotation("Taipei 101", coordinate: .taipei101, anchor: .bottom) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.background)
                        Image(systemName: "house")
                            .padding(5)
                    }
                }
                UserAnnotation()
            }
            .mapControlVisibility(.hidden)
            .mapStyle(.standard(elevation: .realistic))
            .onChange(of: locationManager.region) {
                withAnimation {
                    position = .region(locationManager.region)
                }
            }
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            .overlay(alignment: .topTrailing) {
                VStack {
                    Spacer()
                    MapUserLocationButton(scope: mapScope)
                    MapPitchToggle(scope: mapScope)
                    MapCompass(scope: mapScope)
                        .mapControlVisibility(.visible)
                    Spacer()
                }
                .padding(.trailing, 10)
                .buttonBorderShape(.roundedRectangle)
            }
            .mapScope(mapScope)
            .sheet(isPresented: $isSheetPresented) {
                SearchSheetView(query: $query, isSearching: $isSearching)
            }
        }
    }
}

//#Preview {
//    MapTab()
//}
