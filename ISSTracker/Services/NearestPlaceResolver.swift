import Foundation

final class NearestPlaceResolver: NearestPlaceResolving {
    private enum Policy {
        static let lookupMovementThresholdKilometers = 50.0
    }

    private let cityRecords = OfflineCityIndex.shared
    private var lastResolvedCoordinate: GeoCoordinate?
    private var cachedInsight: PlaceDistanceInsight?

    func resolve(for coordinate: GeoCoordinate) async -> PlaceResolutionResult {
        let distanceFromLastLookup = lastResolvedCoordinate.map {
            OrbitalInsights.haversineKilometers(from: coordinate, to: $0)
        } ?? .infinity

        if distanceFromLastLookup < Policy.lookupMovementThresholdKilometers,
           let cachedInsight = cachedInsight?.updatingDistance(from: coordinate) {
            self.cachedInsight = cachedInsight
            return PlaceResolutionResult(insight: cachedInsight, status: .resolved)
        }

        guard let nearest = nearestCity(to: coordinate) else {
            if let cachedInsight = cachedInsight?.updatingDistance(from: coordinate) {
                self.cachedInsight = cachedInsight
                return PlaceResolutionResult(insight: cachedInsight, status: .resolved)
            }
            return PlaceResolutionResult(insight: nil, status: .unavailable)
        }

        let insight = PlaceDistanceInsight(
            placeName: placeName(for: nearest),
            distanceKilometers: OrbitalInsights.haversineKilometers(from: coordinate, to: nearest.coordinate),
            countryCode: nearest.cc,
            coordinate: nearest.coordinate
        )
        cachedInsight = insight
        lastResolvedCoordinate = coordinate
        return PlaceResolutionResult(insight: insight, status: .resolved)
    }

    private func nearestCity(to coordinate: GeoCoordinate) -> OfflineCityRecord? {
        var bestRecord: OfflineCityRecord?
        var bestDistance = Double.greatestFiniteMagnitude

        for record in cityRecords {
            let distance = OrbitalInsights.haversineKilometers(from: coordinate, to: record.coordinate)
            if distance < bestDistance {
                bestDistance = distance
                bestRecord = record
            }
        }

        return bestRecord
    }

    private func placeName(for record: OfflineCityRecord) -> String {
        guard let country = Locale(identifier: "en_US_POSIX")
            .localizedString(forRegionCode: record.cc),
              !country.isEmpty else {
            return record.n
        }

        return "\(record.n), \(country)"
    }
}
