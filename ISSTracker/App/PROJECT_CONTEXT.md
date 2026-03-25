# ISS Tracker Project Context

## Project Location
- Root: `/Users/kkaisolution/code/ISSTracker`
- App target sources: `/Users/kkaisolution/code/ISSTracker/ISSTracker`
- Xcode project: `/Users/kkaisolution/code/ISSTracker/ISSTracker.xcodeproj`

## What This App Is
- Native iOS app built with SwiftUI and MapKit.
- Single-screen live ISS tracker with a full-screen hybrid globe/map as the primary experience.
- Secondary full-screen details flow now shows a compact gallery of the latest NASA imagery related to the ISS.

## Current Product State
- Live ISS telemetry is fetched from `wheretheiss.at`.
- The map shows:
  - current ISS position
  - predicted forward ground track
  - sun marker
  - nearest-place dot and lightweight floating label
- Top overlay shows:
  - telemetry freshness / live state
  - follow vs explore mode
  - `Details` entry into the image gallery
- Bottom live panel shows:
  - nearest-place headline
  - distance from the station
  - live-state chip
  - one contextual fact such as visibility or speed
  - distance to Riga

## Main Files
- App shell: `/Users/kkaisolution/code/ISSTracker/ISSTracker/App/ISSTrackerApp.swift`
- Root screen: `/Users/kkaisolution/code/ISSTracker/ISSTracker/App/RootView.swift`
- Theme tokens: `/Users/kkaisolution/code/ISSTracker/ISSTracker/App/AppTheme.swift`
- Main screen: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Views/HomeView.swift`
- Globe/map: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Views/GlobeSceneView.swift`
- Bottom live panel: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Views/TelemetryStrip.swift`
- Gallery/details screen: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Views/MediaView.swift`
- Shared card UI: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Views/HUDCard.swift`
- Telemetry model: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Models/ISSTelemetry.swift`
- Place model: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Models/PlaceDistanceInsight.swift`
- Media model: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Models/SpaceMedia.swift`
- Telemetry service: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Services/LiveISSTelemetryService.swift`
- Place resolver: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Services/NearestPlaceResolver.swift`
- Media source: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Services/NASAImageLibraryMediaService.swift`
- Preview-only media source: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Services/MockMediaService.swift`
- Preview gallery data: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Services/PreviewData.swift`
- Home view model: `/Users/kkaisolution/code/ISSTracker/ISSTracker/ViewModels/HomeViewModel.swift`
- Media view model: `/Users/kkaisolution/code/ISSTracker/ISSTracker/ViewModels/MediaViewModel.swift`
- Formatting helpers: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Utilities/Formatters.swift`
- Geo/orbit logic: `/Users/kkaisolution/code/ISSTracker/ISSTracker/Utilities/OrbitalInsights.swift`

## Architecture
- `ISSTrackerApp` composes dependencies through `AppServices`.
- `HomeViewModel` orchestrates polling and merges telemetry with nearest-place resolution.
- `NearestPlaceResolver` owns reverse-geocoding policy, throttling, and caching.
- `LiveISSTelemetryService` is the live transport and produces `TelemetrySnapshot`.
- `MediaViewModel` reloads the gallery payload when details opens and supports manual refresh.
- Views consume already-derived state rather than owning network or geocoder logic directly.

## Current Data Sources
- ISS telemetry and future positions:
  - `https://api.wheretheiss.at/v1/satellites/25544`
  - `https://api.wheretheiss.at/v1/satellites/25544/positions?...`
- Reverse geocoding:
  - Apple `CLGeocoder`
- Gallery production imagery:
  - NASA Image and Video Library search API (`images-api.nasa.gov`)
- Gallery preview imagery:
  - seeded placeholder images from `picsum.photos` used only by preview/mock media
- Country flag rendering:
  - local flag glyph rendering from the country code, with a country-code fallback badge if a glyph cannot be rendered

## Important Current Behaviors
- Dragging the map exits follow mode and switches into explore mode.
- Re-enabling auto-follow recenters the camera while preserving the current viewing style as much as possible.
- Nearest-place resolution now allows country-level placemarks for sparse island/ocean regions.
- Map place labels are lightweight floating text with no background chrome.
- Flags no longer rely on remote CDN image fetches.
- `Details` opens the gallery, not a telemetry sheet.
- Opening `Details` reloads the gallery instead of reusing stale media indefinitely.

## Known Limitations / Technical Debt
- Nearest-place quality still depends on Apple geocoder heuristics.
- Gallery results still depend on NASA search relevance, so some images may be ISS-adjacent rather than direct Earth-window captures.
- Local flag rendering can still fall back to a country-code badge on runtimes where emoji glyph generation is incomplete.
- A local populated-places index would be more reliable than geocoder-only place resolution.
- MapKit label styling is still constrained compared with a custom map renderer.

## Cleanup Status
- The old telemetry detail sheet has been removed from the project.
- The separate `ISSTrackerTests` target and test source files have been removed.
- Snapshot archive of the current UI state exists in:
  - `/Users/kkaisolution/code/ISSTracker/.skill-archive/isst_snapshot_2026-03-25_2013.tgz`

## Suggested Next Improvements
- Improve gallery filtering/ranking if NASA search results are too broad.
- If perfect flag fidelity is required on every runtime, bundle local flag assets instead of relying on local glyph rendering.
- Replace reverse geocoding with a real populated-places dataset for more reliable nearest-place results.
- Add a more deliberate stale/offline treatment for media as well as telemetry.
- Consider separating preview/demo data from production data providers more explicitly.

## Copy-Paste Summary For New Thread
```md
Project is an iOS SwiftUI ISS tracker in `/Users/kkaisolution/code/ISSTracker`.
The app target is in `/Users/kkaisolution/code/ISSTracker/ISSTracker` and the Xcode project is `/Users/kkaisolution/code/ISSTracker/ISSTracker.xcodeproj`.

Current product shape:
- full-screen MapKit hybrid globe
- live ISS telemetry from wheretheiss.at
- predicted ground track
- sun marker
- nearest-place dot and floating label
- top controls for live state, follow/explore, and details
- compact bottom live panel
- details opens a latest-images gallery, not a telemetry sheet

Core files:
- `App/ISSTrackerApp.swift`
- `App/RootView.swift`
- `Views/HomeView.swift`
- `Views/GlobeSceneView.swift`
- `Views/TelemetryStrip.swift`
- `Views/MediaView.swift`
- `ViewModels/HomeViewModel.swift`
- `Services/LiveISSTelemetryService.swift`
- `Services/NearestPlaceResolver.swift`
- `Utilities/OrbitalInsights.swift`

Important caveats:
- nearest-place still relies on Apple CLGeocoder
- flags are rendered as remote image assets, not emoji text
- gallery images come from NASA Image Library in production and preview placeholders in previews
- the old telemetry detail sheet and old test target were removed
```
