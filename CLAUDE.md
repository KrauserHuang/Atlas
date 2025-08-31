# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### Building the Project
```bash
# Build the project in Xcode
open Atlas.xcodeproj
# Then use Cmd+B to build or Cmd+R to run

# Build from command line
xcodebuild -project Atlas.xcodeproj -scheme Atlas -configuration Debug build
```

### Running the App
- Open Atlas.xcodeproj in Xcode
- Select a simulator or device target
- Press Cmd+R to run the app

### Testing
Currently no test framework is set up in this project.

## Project Architecture

### High-Level Structure
Atlas is a SwiftUI-based iOS app with Firebase authentication and location services. The app features a tabbed interface with map, list, and profile views.

### Key Components

**Authentication Flow**
- Uses Firebase Authentication with email/password and third-party providers
- `AuthenticationViewModel` manages auth state with reactive properties
- Complete signup/login flow with `SignupView` and `LoginView`
- Supports Google Sign-In and Apple Sign-In (setup required)
- Email validation, password strength checking, and form validation
- `AuthenticatedView` wraps the main app content
- Authentication UI is now active in `AtlasApp.swift`

**Tab-Based Navigation**
- `AppTab` enum defines three tabs: map, list, profile
- Each tab has its own view and can be accessed independently
- Tab system supports localization with `LocalizedStringKey`

**Location Services**
- `LocationManager` is a singleton using the new `@Observable` macro
- Handles CLLocationManager delegation and MKLocalSearch functionality
- Supports location search with autocomplete via `MKLocalSearchCompleter`
- Provides directions between locations
- Contains custom error handling with `LocationError` enum

**Search Functionality**
- `SearchResult` and `SearchCompletion` models for location search
- Map-based search with current location context
- Search autocompletion with point-of-interest filtering

### Dependencies
- Firebase SDK (version 11.11.0):
  - FirebaseAnalytics
  - FirebaseAuth
  - FirebaseAuthCombine-Community
  - FirebaseCore
- MapKit for location services
- SwiftUI for UI framework

### File Organization
```
Atlas/
├── App/
│   ├── Auth/           # Authentication views and view models
│   └── Tabs/           # Tab-based navigation and individual tab views
├── Extensions/         # Swift extensions for CLLocationCoordinate2D and MKCoordinateRegion
├── Utilities/          # Location services and managers
├── Assets.xcassets/    # App icons and image assets
└── AtlasApp.swift      # Main app entry point
```

### Key Implementation Details
- Uses iOS 18.2 as minimum deployment target
- Implements the new `@Observable` macro for state management instead of `ObservableObject`
- LocationManager accesses private MKLocalSearchCompleter API using KVC (line 246 in LocationManager.swift)
- Firebase configuration is loaded from `GoogleService-Info.plist`
- Location permission required: "We are going to use the location for map to function"

### Development Notes
- The app uses Swift 5.0 and targets both iPhone and iPad
- Development team ID: 6U2TAM5353
- Bundle identifier: com.krauserhuang.Atlas
- Comments in code are written in Traditional Chinese

### Third-Party Authentication Setup
- **Google Sign-In**: Requires GoogleSignIn SDK and setup instructions in `GoogleSignIn-Setup-Instructions.md`
- **Apple Sign-In**: Requires enabling Sign In with Apple capability, setup instructions in `AppleSignIn-Setup-Instructions.md`
- Both integrations are prepared but require additional setup steps to be fully functional