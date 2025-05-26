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

/// This macro adds observation support to a custom type and conforms the type to the `Observable` protocol.
/// - 遵從`ObservableObject`協定 → 自動加上`objectWillChange Publisher`
/// - 所有屬性自動套上等同於`@Published`的行為（原先使用ObservableObject協定，要先import Combine/標記 @Published，若有自訂setter，還要呼叫objectWillChange.send()）
@Observable
final class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    let manager: CLLocationManager = CLLocationManager()
    var region: MKCoordinateRegion = MKCoordinateRegion()
    var error: LocationError? = nil
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
}

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
