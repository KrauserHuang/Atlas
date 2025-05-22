//
//  ListView.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/5/15.
//

import SwiftUI

struct ListView: View {
    var body: some View {
        NavigationView {
            List(1...20, id: \.self) { item in
                Text("Item \(item)")
            }
            .navigationTitle("List")
        }
    }
}

//#Preview {
//    ListView()
//}
