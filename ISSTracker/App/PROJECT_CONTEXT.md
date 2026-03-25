# ISS Tracker Project Context

## Project Location
- Root: `/Users/kkaisolution/Documents/New project`
- iOS app: `/Users/kkaisolution/Documents/New project/ISSTracker`
- Xcode project: `/Users/kkaisolution/Documents/New project/ISSTracker.xcodeproj`

## What This App Is
- Native iOS app built with SwiftUI.
- Main experience is a full-screen interactive globe/map showing the ISS over Apple Maps imagery/hybrid tiles.
- The app is currently a single-screen app, not a tabbed app.

## Current Product State
- Live ISS position is fetched from `wheretheiss.at`.
- The visible ISS path is based on predicted forward positions from the same API.
- A sun marker is shown using the API-provided solar subpoint.
- A red footprint circle is shown around the ISS.
- A bottom telemetry overlay shows:
  - Altitude
  - Speed
  - Distance to Riga
  - Nearest place
- Top overlay buttons:
  - Updated time
  - Telemetry
  - Free explore / Resume follow

## Main Files
- App shell: `/Users/kkaisolution/Documents/New project/ISSTracker/App/ISSTrackerApp.swift`
- Root screen: `/Users/kkaisolution/Documents/New project/ISSTracker/App/RootView.swift`
- Main screen: `/Users/kkaisolution/Documents/New project/ISSTracker/Views/HomeView.swift`
- Globe/map: `/Users/kkaisolution/Documents/New project/ISSTracker/Views/GlobeSceneView.swift`
- Telemetry overlay: `/Users/kkaisolution/Documents/New project/ISSTracker/Views/TelemetryStrip.swift`
- Details now open the latest-images gallery in `/Users/kkaisolution/code/ISSTracker/ISSTracker/Views/MediaView.swift`
- Models: `/Users/kkaisolution/Documents/New project/ISSTracker/Models/ISSTelemetry.swift`
- Data service: `/Users/kkaisolution/Documents/New project/ISSTracker/Services/LiveISSTelemetryService.swift`
- View model: `/Users/kkaisolution/Documents/New project/ISSTracker/ViewModels/HomeViewModel.swift`
- Utility + place logic: `/Users/kkaisolution/Documents/New project/ISSTracker/Utilities/Formatters.swift`
- App icon assets: `/Users/kkaisolution/Documents/New project/ISSTracker/Assets.xcassets`

## Architecture
- `HomeViewModel` owns refresh and geocoding state.
- `LiveISSTelemetryService` fetches live ISS data and predicted positions from `wheretheiss.at`, with fallback values if network fails.
- `GlobeSceneView` renders the map using SwiftUI `Map`.
- `TelemetryStrip` renders the bottom compact telemetry cards.
- `nearestPlaceInsight` is resolved asynchronously in `HomeViewModel` and is used by both:
  - telemetry widget
  - nearest-place map annotation

## Current Data Sources
- ISS telemetry and future positions:
  - `https://api.wheretheiss.at/v1/satellites/25544`
  - `https://api.wheretheiss.at/v1/satellites/25544/positions?...`
- Reverse geocoding / place naming:
  - Apple `CLGeocoder`

## Important Current Behaviors
- `Free explore` and `Resume follow` are controlled from `HomeView`.
- `GlobeSceneView` preserves current zoom/pitch/heading while following ISS.
- The nearest-place label can show a country flag emoji if `isoCountryCode` is available.
- The nearest-place map annotation is:
  - a small red dot at the resolved place coordinate
  - a separate offset label so it does not sit directly on the dot

## Known Limitations / Technical Debt
- Live telemetry and fallback generation should remain clearly separated.
- Nearest-place logic still depends on Apple geocoding heuristics.
- Apple geocoding was hitting throttling before; mitigation is now in place:
  - nearest-place is only recomputed after sufficient movement
  - outward settlement search ring is limited
- If nearest-place quality still matters, the proper fix is:
  - use a local populated-places dataset, or
  - use a dedicated geospatial/place service
- MapKit built-in labels are not customizable, so country names on the globe cannot be decorated directly.

## Recent UX Decisions
- Media screen was removed.
- Telemetry cards were made compact and pinned at the bottom.
- Country flags were added to nearest-place labels.
- Custom ISS marker is procedurally drawn in code.
- Nearest-place marker was simplified to a red dot plus offset label.

## Current Problems To Be Aware Of
- Nearest-place can still be imperfect over oceans or remote regions because of geocoder quality.
- If a place name is correct but the map point is wrong, the likely cause is geocoder ambiguity, not the annotation UI.
- If nearest-place becomes stuck on `Resolving...`, geocoder throttling or poor locality results are the first things to inspect.

## Suggested Next Improvements
- Keep `LiveISSTelemetryService` as the live transport and isolate fallback generation from transport responsibilities.
- Separate live telemetry service from fallback/mock preview service.
- Replace Apple geocoder nearest-place logic with a real populated-places index.
- Improve nearest-place selection rules for ocean / remote landmass cases.
- Add explicit loading / stale-state handling for nearest-place resolution.
- Consider moving from SwiftUI `Map` to `MKMapView` wrapper if touch/annotation control becomes limiting again.

## Copy-Paste Summary For New Thread
```md
Project is an iOS SwiftUI ISS tracker in `/Users/kkaisolution/Documents/New project`.
Main app folder is `/Users/kkaisolution/Documents/New project/ISSTracker`.
The app currently shows a full-screen MapKit hybrid globe with:
- live ISS position from wheretheiss.at
- predicted path based on future positions from the same API
- sun subsolar point marker
- ISS footprint circle
- bottom telemetry cards for altitude, speed, distance to Riga, nearest place
- top controls for updated time, telemetry sheet, and free-explore/follow toggle

Main files:
- `ISSTracker/Views/HomeView.swift`
- `ISSTracker/Views/GlobeSceneView.swift`
- `ISSTracker/Views/TelemetryStrip.swift`
- `ISSTracker/ViewModels/HomeViewModel.swift`
- `ISSTracker/Services/LiveISSTelemetryService.swift`
- `ISSTracker/Utilities/Formatters.swift`
- `ISSTracker/Models/ISSTelemetry.swift`

Important caveat:
- `LiveISSTelemetryService` is the live telemetry transport.
- nearest-place currently uses Apple CLGeocoder and is the weakest part of the app.
- nearest-place map marker is a red dot plus offset label; widget and map annotation use the same resolved place state.
```
