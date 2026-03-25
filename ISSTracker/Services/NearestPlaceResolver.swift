import CoreLocation
import Foundation

final class NearestPlaceResolver: NearestPlaceResolving {
    private enum Policy {
        static let geocodeMovementThresholdKilometers = 250.0
        static let minimumSecondsBetweenGeocodeAttempts: TimeInterval = 30
        static let geocodeBackoffAfterFailure: TimeInterval = 90
    }

    private let geocoder = CLGeocoder()
    private var requestID = 0
    private var lastGeocodedCoordinate: GeoCoordinate?
    private var lastAttemptAt: Date?
    private var nextAllowedAt: Date = .distantPast
    private var cachedInsight: PlaceDistanceInsight?

    func resolve(for coordinate: GeoCoordinate) async -> PlaceResolutionResult {
        let now = Date()

        if let cachedInsight {
            self.cachedInsight = cachedInsight.updatingDistance(from: coordinate)
        }

        let distanceFromLastGeocode = lastGeocodedCoordinate.map {
            OrbitalInsights.haversineKilometers(from: coordinate, to: $0)
        } ?? .infinity
        let secondsSinceLastAttempt = lastAttemptAt.map { now.timeIntervalSince($0) } ?? .infinity
        let shouldRefreshGeocode =
            distanceFromLastGeocode >= Policy.geocodeMovementThresholdKilometers
            && secondsSinceLastAttempt >= Policy.minimumSecondsBetweenGeocodeAttempts
            && now >= nextAllowedAt

        guard shouldRefreshGeocode else {
            if let cachedInsight {
                return PlaceResolutionResult(insight: cachedInsight, status: .resolved)
            }
            return PlaceResolutionResult(
                insight: nil,
                status: lastAttemptAt == nil ? .resolving : .unavailable
            )
        }

        requestID += 1
        let currentRequestID = requestID
        lastAttemptAt = now
        geocoder.cancelGeocode()

        do {
            for searchCoordinate in OrbitalInsights.settlementSearchCoordinates(from: coordinate) {
                let placemarks = try await geocoder.reverseGeocodeLocation(
                    CLLocation(latitude: searchCoordinate.latitude, longitude: searchCoordinate.longitude)
                )

                guard currentRequestID == requestID else {
                    return PlaceResolutionResult(insight: cachedInsight, status: .resolved)
                }

                if let place = placemarks.first,
                   OrbitalInsights.isSettlementPlacemark(place),
                   let insight = OrbitalInsights.placeInsight(from: place, issCoordinate: coordinate) {
                    cachedInsight = insight
                    lastGeocodedCoordinate = coordinate
                    nextAllowedAt = now.addingTimeInterval(Policy.minimumSecondsBetweenGeocodeAttempts)
                    return PlaceResolutionResult(insight: insight, status: .resolved)
                }
            }

            cachedInsight = nil
            nextAllowedAt = now.addingTimeInterval(Policy.geocodeBackoffAfterFailure)
            return PlaceResolutionResult(insight: nil, status: .unavailable)
        } catch {
            guard currentRequestID == requestID else {
                return PlaceResolutionResult(insight: cachedInsight, status: .resolved)
            }
            cachedInsight = nil
            nextAllowedAt = now.addingTimeInterval(Policy.geocodeBackoffAfterFailure)
            return PlaceResolutionResult(insight: nil, status: .unavailable)
        }
    }
}
