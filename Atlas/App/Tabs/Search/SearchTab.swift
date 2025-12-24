//
//  SearchTab.swift
//  Atlas
//
//  Created by IT-MAC-02 on 2025/12/09.
//

import MapKit
import SwiftUI

struct SearchTab: View {

    @Binding var searchText: String
    @State private var locationManager = LocationManager.shared
    @State private var searchResults: [Place] = []
    @State private var selectedLocation: Place?

    var body: some View {
        VStack {
            if !searchResults.isEmpty {
                List {
                    ForEach(searchResults, id: \.self) { result in
                        Button(action: {
                            selectedLocation = result
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.mapItem.name ?? "Unknown")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                if let address = result.mapItem.address?.fullAddress {
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            } else if searchText.isEmpty {
                // Empty state - no search yet
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("Search for a location")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Enter a location name, address, or place")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                // Searching or no results
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("No results found")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Try searching for a different location")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            }
        }
        .navigationTitle("Search")
        .onChange(of: searchText) { _, newQuery in
            if !newQuery.isEmpty {
                performSearch(newQuery)
            } else {
                searchResults = []
            }
        }
        .sheet(item: $selectedLocation) { location in
            NavigationStack {
                LocationDetailView(searchResult: location)
            }
        }
    }

    private func performSearch(_ query: String) {
        Task {
            do {
                let results = try await locationManager.performSearch(with: query)
                await MainActor.run {
                    searchResults = results
                }
            } catch {
                print("Search failed: \(error)")
                await MainActor.run {
                    searchResults = []
                }
            }
        }
    }
}

struct LocationDetailView: View {
    let searchResult: Place

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(searchResult.mapItem.name ?? "Unknown Location")
                        .font(.title2)
                        .fontWeight(.bold)

                    if let address = searchResult.mapItem.address?.fullAddress {
                        Text(address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            if let phoneNumber = searchResult.mapItem.phoneNumber {
                Section("Contact") {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.blue)
                        Text(phoneNumber)
                        Spacer()
                        Link("Call", destination: URL(string: "tel:\(phoneNumber)")!)
                            .font(.subheadline)
                    }
                }
            }

            if let url = searchResult.mapItem.url {
                Section("Website") {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundStyle(.blue)
                            Text(url.absoluteString)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Location") {
                let coordinate = searchResult.mapItem.location.coordinate
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Latitude:")
                            .foregroundStyle(.secondary)
                        Text("\(coordinate.latitude)")
                    }
                    HStack {
                        Text("Longitude:")
                            .foregroundStyle(.secondary)
                        Text("\(coordinate.longitude)")
                    }
                }
                .font(.subheadline)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
