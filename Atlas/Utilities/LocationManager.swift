//
//  LocationManager.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/23.
//

import MapKit
import Observation

enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return NSLocalizedString("Location access denied.", comment: "")
        case .authorizationRestricted:
            return NSLocalizedString("Location authorization restricted.", comment: "")
        case .unknownLocation:
            return NSLocalizedString("Unknown location.", comment: "")
        case .accessDenied:
            return NSLocalizedString("Access denied.", comment: "")
        case .network:
            return NSLocalizedString("Network failed.", comment: "")
        case .operationFailed:
            return NSLocalizedString("Operation failed.", comment: "")
        }
    }
}

/// 儲存搜尋自動完成建議結果的model
struct SearchCompletion: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    var url: URL?
}

/// 搜尋結果的model
struct Place: Identifiable, Hashable {
    let id = UUID()
    let mapItem: MKMapItem
    
    var name: String { mapItem.name ?? "Unknown" }
    var coordinate: CLLocationCoordinate2D { mapItem.location.coordinate }
    var address: String { mapItem.address?.fullAddress ?? "" }
    var phoneNumber: String? { mapItem.phoneNumber }
}

/// This macro adds observation support to a custom type and conforms the type to the `Observable` protocol.
/// - 遵從`ObservableObject`協定 → 自動加上`objectWillChange Publisher`
/// - 所有屬性自動套上等同於`@Published`的行為（原先使用ObservableObject協定，要先import Combine/標記 @Published，若有自訂setter，還要呼叫objectWillChange.send()）
@Observable
final class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    let manager: CLLocationManager = CLLocationManager()
    var region: MKCoordinateRegion = MKCoordinateRegion()
    var location: CLLocationCoordinate2D? = nil
    var name: String = ""
    var error: LocationError? = nil
    // Search Properties
    var query: String = ""
    var searchResults: [Place] = []
    var selectedResult: Place?
    var showSearchResults: Bool = false
    var isSearching: Bool = false
    var completions: [SearchCompletion] = []
    let searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        // 初始化 CLLocationManager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // 初始化 MKLocalSearchCompleter
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
    }
    
    /// 執行位置搜尋
    /// - Parameters:
    ///   - query: 搜尋的字串
    ///   - useCurrentLocation: 是否依目前位置當作座標中心進行搜尋
    /// - Returns: 回傳搜尋結果
    func performSearch(with query: String, useCurrentLocation: Bool = true) async throws -> [Place] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        if useCurrentLocation {
            if let location {
                request.region = MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
                )
            } else if region.center.latitude != 0 && region.center.longitude != 0 {
                request.region = region
            }
        }
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        let results = response.mapItems.map { Place(mapItem: $0) }
        
        await MainActor.run {
            self.searchResults = results
        }
        
        return results
    }
    
    func updateSearchCompletions(queryFragment: String) {
        query = queryFragment
        if queryFragment.isEmpty {
            completions = []
        } else {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    func searchFromCompletion(_ completion: SearchCompletion) async throws -> [Place] {
        return try await performSearch(with: completion.title)
    }
    
    func clearSearchResults() {
        searchResults = []
        completions = []
        query = ""
        searchCompleter.queryFragment = ""
    }
    
    /// Get directions between two locations
    /// - Parameters:
    ///   - from: Starting location (nil for current location)
    ///   - to: Destination location
    /// - Returns: MKRoute object with directions
    func getDirections(from: CLLocationCoordinate2D? = nil, to: CLLocationCoordinate2D) async throws -> MKRoute {
        let request = MKDirections.Request()
        
        // Set source
        if let fromLocation = from {
            request.source = MKMapItem(location: CLLocation(latitude: fromLocation.latitude, longitude: fromLocation.longitude), address: nil)
        } else if let currentLocation = location {
            request.source = MKMapItem(location: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude), address: nil)
        } else {
            request.source = MKMapItem.forCurrentLocation()
        }
        
        // Set destination
        request.destination = MKMapItem(location: CLLocation(latitude: to.latitude, longitude: to.longitude), address: nil)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        
        guard let route = response.routes.first else {
            throw LocationError.operationFailed
        }
        
        return route
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    /// 任何時候只要authorizationStatus改變就會呼叫這個方法
    /// - Parameter manager: 傳遞位置相關資訊的物件
    /// `notDetermined` → 尚未詢問使用者，要出「使用時授權」對話框
    /// `authorizedAlways` & `authorizedWhenInUse` → 已取得授權，像系統請求一次定位結果
    /// `denied` → 使用者拒絕授權
    /// `restricted` → 被系統限制
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied:
            print("Location permission denied")
        case .restricted:
            print("Location permission restricted")
        default:
            break
        }
    }
    
    /// 每次更新位置都會呼叫這個方法(eg. `requestLocation`/`startUpdatingLocation`執行時)
    /// - Parameters:
    ///   - manager: 傳遞位置相關資訊的物件
    ///   - locations: 把一次或多次定位結果存進這個array裡
    ///   `span` → 地圖縮放範圍
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    /// 定位發生錯誤時呼叫(eg. 權限拒絕、硬體拿不到定位、網路問題)
    /// - Parameters:
    ///   - manager: 傳遞位置相關資訊的物件
    ///   - error: 錯誤內容
    ///   把與`CLError`相關的錯誤回傳對應到`LocationError`上
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                self.error = .accessDenied
            case .network:
                self.error = .network
            case .locationUnknown:
                self.error = .unknownLocation
            default:
                self.error = .operationFailed
            }
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension LocationManager: MKLocalSearchCompleterDelegate {
    /// 當`completer`完成更新結果時呼叫
    /// - Parameter completer: 完成器的實體物件
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { completion in
            // 使用 Key-Value Coding(KVC) 取得私有屬性 "_mapItem"
            // ‼️ 這是存取 Apple 私有 API 的方式，可能未來版本失效、在 App Store 審查中可能會被拒絕
            let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem
            
            return .init(
                title: completion.title,
                subTitle: completion.subtitle,
                url: mapItem?.url
            )
        }
        
        searchResults = completer.results.compactMap { completion in
            let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem
            if let mapItem {
                return Place(mapItem: mapItem)
            }
            return nil
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print("Search completer failed: \(error.localizedDescription)")
    }
}

