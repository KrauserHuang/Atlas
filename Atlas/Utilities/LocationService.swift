//
//  LocationService.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/27.
//

import MapKit

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
}

@Observable
class LocationService: NSObject {
    private let completer: MKLocalSearchCompleter
    
    var completions: [SearchCompletions] = []
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        completer.delegate = self
    }
    
    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
    }
}

extension LocationService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { .init(title: $0.title, subTitle: $0.subtitle) }
    }
}
