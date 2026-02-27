# Next to Go — Entain Take-Home

An iOS app displaying the next 5 upcoming races from the Neds API, with live countdowns and category filtering.

## Features

- **Live countdowns** — Updates every second using `TimelineView` (no ViewModel timer)
- **Category filtering** — Filter by Horse, Harness, or Greyhound; deselect all to show everything
- **Auto-refresh** — Expired races (>60s past start) are pruned; list auto-fills to 5
- **Loading & Error states** — Lottie animations with retry support
- **Accessibility** — Full VoiceOver support, Dynamic Type, Voice Control labels

## Architecture

```
Entain/
├── Entain/                      ← App target (DI wiring, EntainApp.swift)
├── Packages/
│   ├── Model/                   ← Domain types + RaceService protocol
│   ├── Services/                ← NetworkService actor + DefaultRaceService + API DTOs
│   ├── ViewModels/              ← RaceListViewModel
│   └── UI/                      ← All SwiftUI views
├── .swiftlint.yml
└── Entain.xcodeproj
```

**Dependency graph** (no cycles):
```
Model ← Services
Model ← ViewModels ← UI ← App
```

The `ViewModels` package depends only on the `RaceService` **protocol** from Model. The App target injects `DefaultRaceService` at startup.

## Requirements

- Xcode 16.0+
- iOS 18.0 deployment target
- Swift 6

## Build & Run

1. Open `Entain.xcodeproj` in Xcode
2. Select any available iOS simulator (example: iPhone 17)
3. Press `Cmd+R`

The app fetches live data from `api.neds.com.au` — an internet connection is required.

### Command-Line Build

```bash
xcodebuild build \
  -project Entain.xcodeproj \
  -scheme Entain \
  -destination "platform=iOS Simulator,name=iPhone 17" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

## Running Tests

```bash
# All tests via Xcode
xcodebuild test -project Entain.xcodeproj -scheme Entain \
  -destination "platform=iOS Simulator,name=iPhone 17" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Package-level tests (direct package run, optional)
swift test --package-path Packages/ViewModels
```

## Regenerate Xcode Project

```bash
xcodegen generate
```

## Testing Checklist

- `RaceListViewModelTests`:
  - Fetches and limits to 5 visible races
  - Filters by category, deselect-all shows all
  - Races past 60s are excluded from visible list
  - Triggers refetch when below 5 races
  - Error surfacing and retry flow
- `RaceRowViewModelTests`:
  - Localized countdown formatting for future/past races
  - Singular/plural minute and second formatting
  - Accessibility and static label formatting
- `EntainTests`:
  - Project-level XCTest smoke test target for `xcodebuild test`

## Verification

| Check | How |
|-------|-----|
| Build | `Cmd+B` in Xcode → 0 errors |
| Run | `Cmd+R` → app shows 5 live races |
| Filter | Tap category chip → list filters |
| Expiry | Use `MockRaceService` with expired start date |
| Tests | Run `xcodebuild test ...` (includes package tests) and/or direct `swift test --package-path ...` |
| VoiceOver | Enable in Simulator → race rows announce full info |
| Dynamic Type | Increase text size → layout adapts |
| SwiftLint | Build log shows 0 violations |

## API Reference

```
GET https://api.neds.com.au/rest/v1/racing/?method=nextraces&count=10
```

| Category   | UUID |
|------------|------|
| Horse      | `4a2788f8-e825-4d36-9894-efd4baf1cfae` |
| Harness    | `161d9be2-e909-4326-8c2c-35ed71fb460b` |
| Greyhound  | `9daef0d7-bf3c-4f50-921d-8e818c60fe61` |

## Design Decisions

- **`@Observable` + `@MainActor`**: Swift Observation framework eliminates Combine boilerplate. All state mutations happen on the main actor.
- **`TimelineView` for countdowns**: The view drives the timer, not the ViewModel. This cleanly separates business logic (race expiry) from display concerns (seconds ticking).
- **Actor-based networking**: `NetworkService` is an `actor`, guaranteeing safe concurrent access to `URLSession`.
- **Protocol-first DI**: `RaceService` protocol in Model means ViewModels are fully testable without touching the network layer.
- **Local Swift Packages**: Clean module boundaries with explicit dependency graph, faster incremental builds, and clear ownership of each layer.

## Future Improvements

- [ ] Persist cached races to survive app backgrounding (Core Data or SwiftData)
- [ ] Support landscape and iPad layouts
- [ ] Add haptic feedback on category toggle
- [ ] Support `.dotlottie` format animations for smaller bundle size
- [ ] Snapshot tests for `RaceRowView` and `FilterBarView`
- [ ] Integration/UI tests using `XCTest` and live mock server
- [ ] Localisation support (race categories, countdown labels)

## Lottie Animations

Placeholder animations are bundled (simple spinning arc for loading, pulsing circle for error). Replace with polished animations from [LottieFiles](https://lottiefiles.com) for production — the bundle resource paths are:

- `racing_loading.json` — used by `LoadingView`
- `error_animation.json` — used by `ErrorView`
