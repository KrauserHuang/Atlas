//
//  MapView.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/15.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        Text("Map")
    }
}

//#Preview {
//    MapView()
//}
