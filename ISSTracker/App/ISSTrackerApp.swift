import SwiftUI

@main
struct ISSTrackerApp: App {
    private let services = AppServices.live

    var body: some Scene {
        WindowGroup {
            RootView(
                homeViewModel: HomeViewModel(
                    telemetryProvider: services.telemetryProvider,
                    nearestPlaceResolver: services.nearestPlaceResolver
                ),
                mediaViewModel: MediaViewModel(mediaProvider: services.mediaProvider)
            )
        }
    }
}
