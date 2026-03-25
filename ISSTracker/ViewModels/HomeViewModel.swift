import Foundation

enum NearestPlaceStatus: Equatable {
    case idle
    case resolving
    case resolved
    case unavailable
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var telemetry: ISSTelemetry?
    @Published private(set) var telemetrySource: TelemetrySource = .live
    @Published private(set) var lastUpdatedAt: Date?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isRefreshing = false
    @Published private(set) var nearestPlaceInsight: PlaceDistanceInsight?
    @Published private(set) var nearestPlaceStatus: NearestPlaceStatus = .idle

    private let telemetryProvider: ISSTelemetryProviding
    private let nearestPlaceResolver: NearestPlaceResolving
    private var refreshTask: Task<Void, Never>?

    init(
        telemetryProvider: ISSTelemetryProviding,
        nearestPlaceResolver: NearestPlaceResolving
    ) {
        self.telemetryProvider = telemetryProvider
        self.nearestPlaceResolver = nearestPlaceResolver
    }

    func start() {
        guard refreshTask == nil else { return }

        refreshTask = Task {
            await refresh()

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                await refresh()
            }
        }
    }

    func stop() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let snapshot = try await telemetryProvider.currentTelemetry()
            telemetry = snapshot.telemetry
            telemetrySource = snapshot.source
            lastUpdatedAt = snapshot.fetchedAt
            errorMessage = nil
            await refreshNearestPlace(for: snapshot.telemetry.coordinate)
        } catch {
            errorMessage = "Unable to refresh telemetry."
        }
    }

    private func refreshNearestPlace(for coordinate: GeoCoordinate) async {
        let result = await nearestPlaceResolver.resolve(for: coordinate)
        nearestPlaceInsight = result.insight
        nearestPlaceStatus = result.status
    }
}
