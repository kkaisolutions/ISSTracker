import SwiftUI

struct RootView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var mediaViewModel: MediaViewModel

    init(homeViewModel: HomeViewModel, mediaViewModel: MediaViewModel) {
        _homeViewModel = StateObject(wrappedValue: homeViewModel)
        _mediaViewModel = StateObject(wrappedValue: mediaViewModel)
    }

    var body: some View {
        HomeView(viewModel: homeViewModel, mediaViewModel: mediaViewModel)
            .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView(
        homeViewModel: HomeViewModel(
            telemetryProvider: LiveISSTelemetryService(),
            nearestPlaceResolver: NearestPlaceResolver()
        ),
        mediaViewModel: MediaViewModel(mediaProvider: MockMediaService())
    )
}
