//
//  LocationService.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/27.
//

import MapKit

/// 儲存搜尋結果的model
struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    var url: URL?
}

@Observable
class LocationService: NSObject {
    /// 本地搜尋自動完成器
    private let completer: MKLocalSearchCompleter
    /// 搜尋結果會存入此陣列
    var completions: [SearchCompletions] = []
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        completer.delegate = self
    }
    
    /// 更新搜尋結果
    /// - Parameter queryFragment: 使用者輸入的搜尋片段
    /// `resultTypes` → 設定搜尋結果類型為興趣點，即結果還會過濾成只顯示店家、景點等已標示地點
    /// `queryFragment` → 設定搜尋字串，當該屬性被設定時，completer會自動開始搜尋
    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
    }
}

extension LocationService: MKLocalSearchCompleterDelegate {
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
    }
}
