import Foundation

protocol ISSTelemetryProviding {
    func currentTelemetry() async throws -> TelemetrySnapshot
}

struct PlaceResolutionResult: Equatable {
    let insight: PlaceDistanceInsight?
    let status: NearestPlaceStatus
}

protocol NearestPlaceResolving {
    func resolve(for coordinate: GeoCoordinate) async -> PlaceResolutionResult
}

protocol MediaProviding {
    func loadMedia() async throws -> MediaPayload
}

struct AppServices {
    let telemetryProvider: ISSTelemetryProviding
    let nearestPlaceResolver: NearestPlaceResolving
    let mediaProvider: MediaProviding

    static let live = AppServices(
        telemetryProvider: LiveISSTelemetryService(),
        nearestPlaceResolver: NearestPlaceResolver(),
        mediaProvider: NASAImageLibraryMediaService()
    )

    static let preview = AppServices(
        telemetryProvider: LiveISSTelemetryService(),
        nearestPlaceResolver: NearestPlaceResolver(),
        mediaProvider: MockMediaService()
    )
}
