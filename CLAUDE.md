# Entain — Next to Go

## Project Overview

iOS take-home app displaying "Next to Go" races from the Neds API, built as a modular Swift Package project.

## Architecture

Modular Swift Package structure with strict unidirectional dependency flow:

```
Model ← Services
Model ← ViewModels ← UI ← App
```

- **Model** — Domain types (`Race`, `RaceCategory`), `RaceService` protocol, `CountdownFormatter`
- **Services** — `NetworkService` actor, `DefaultRaceService`, API DTOs
- **ViewModels** — `RaceListViewModel` (`@Observable`, `@MainActor`)
- **UI** — All SwiftUI views and native animations
- **App** — Entry point, dependency injection

## Key Conventions

- Swift 6 strict concurrency throughout — no `Sendable` suppressions
- `@Observable` + `@MainActor` for ViewModels — no Combine, no `@Published`
- `CountdownLabel` uses `TimelineView(.periodic(from:by:1))` for second-by-second display — no ViewModel timer
- ViewModels depend only on the `RaceService` protocol (from Model), never on Services directly
- SwiftLint runs on every build via run-script phase

## Build & Run

```bash
# Open in Xcode
open Entain.xcodeproj

# Build from command line
xcodebuild build -project Entain.xcodeproj -scheme Entain \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Run all tests from Entain scheme
xcodebuild test -project Entain.xcodeproj -scheme Entain \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# Run package tests directly (optional)
swift test --package-path Packages/ViewModels
```

## Regenerate Xcode Project

```bash
xcodegen generate
```

## SwiftLint

```bash
swiftlint --config .swiftlint.yml
```

## Testing Notes

- `CountdownFormatterTests` — pure unit tests, no async
- `RaceListViewModelTests` — uses `MockRaceService`, covers filtering, expiry, refill, error handling
- `@MainActor` isolation on the ViewModel requires tests to be `@MainActor` too

## UI Animations

Loading and error screens use native SwiftUI animation primitives and SF Symbols.
