import Contacts
import CoreLocation
import Foundation

enum OrbitalInsights {
    private static let riga = GeoNamedPlace(
        name: "Riga, Latvia",
        coordinate: GeoCoordinate(latitude: 56.9496, longitude: 24.1052)
    )

    static func distanceToRiga(from coordinate: GeoCoordinate) -> PlaceDistanceInsight {
        PlaceDistanceInsight(
            placeName: riga.name,
            distanceKilometers: haversineKilometers(from: coordinate, to: riga.coordinate),
            countryCode: "LV",
            coordinate: riga.coordinate
        )
    }

    static func placeInsight(
        from placemark: CLPlacemark,
        issCoordinate: GeoCoordinate
    ) -> PlaceDistanceInsight? {
        guard let location = placemark.location else { return nil }

        let city = placemark.locality
            ?? placemark.subLocality
            ?? placemark.name
        let country = placemark.country
        let primaryPlace = city ?? country

        guard let primaryPlace else { return nil }

        let label: String
        if let country, !country.isEmpty, primaryPlace.caseInsensitiveCompare(country) != .orderedSame {
            label = "\(primaryPlace), \(country)"
        } else {
            label = primaryPlace
        }

        let placeCoordinate = GeoCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let countryCode = placemark.isoCountryCode ?? inferredCountryCode(from: country)

        return PlaceDistanceInsight(
            placeName: label,
            distanceKilometers: haversineKilometers(from: issCoordinate, to: placeCoordinate),
            countryCode: countryCode,
            coordinate: placeCoordinate
        )
    }

    static func isSettlementPlacemark(_ placemark: CLPlacemark) -> Bool {
        let candidateTerms = [
            placemark.locality,
            placemark.subLocality,
            placemark.name
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        guard !candidateTerms.isEmpty else { return false }

        let forbiddenTerms = [
            "sea", "ocean", "bay", "gulf", "strait", "channel", "lake", "river",
            "desert", "mountains", "mountain", "range", "forest", "reef"
        ]

        for term in candidateTerms {
            let lowered = term.lowercased()
            if forbiddenTerms.contains(where: { lowered.contains($0) }) {
                return false
            }
        }

        if placemark.locality != nil || placemark.subLocality != nil {
            return true
        }

        return placemark.country != nil && placemark.ocean == nil && placemark.inlandWater == nil
    }

    static func settlementSearchCoordinates(from origin: GeoCoordinate) -> [GeoCoordinate] {
        var results: [GeoCoordinate] = [origin]
        let latitudeSteps: [Double] = [1.0, 2.5, 5.0, 8.0, 12.0]

        for step in latitudeSteps {
            let longitudeScale = max(cos(origin.latitude * .pi / 180), 0.25)
            let lonStep = step / longitudeScale

            let offsets: [(Double, Double)] = [
                ( step, 0), (-step, 0), (0, lonStep), (0, -lonStep),
                ( step, lonStep), ( step, -lonStep), (-step, lonStep), (-step, -lonStep)
            ]

            for offset in offsets {
                results.append(
                    GeoCoordinate(
                        latitude: max(-89.9, min(89.9, origin.latitude + offset.0)),
                        longitude: normalizedLongitude(origin.longitude + offset.1)
                    )
                )
            }
        }

        return results
    }

    static func haversineKilometers(from: GeoCoordinate, to: GeoCoordinate) -> Double {
        let earthRadius = 6_371.0
        let dLat = (to.latitude - from.latitude) * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        let originLat = from.latitude * .pi / 180
        let destinationLat = to.latitude * .pi / 180

        let a = pow(sin(dLat / 2), 2) + cos(originLat) * cos(destinationLat) * pow(sin(dLon / 2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }

    private static func normalizedLongitude(_ longitude: Double) -> Double {
        var value = longitude
        while value > 180 { value -= 360 }
        while value < -180 { value += 360 }
        return value
    }

    private static func inferredCountryCode(from countryName: String?) -> String? {
        guard let countryName else { return nil }

        let locale = Locale(identifier: "en_US_POSIX")
        return Locale.Region.isoRegions.first {
            locale.localizedString(forRegionCode: $0.identifier)?.caseInsensitiveCompare(countryName) == .orderedSame
        }?.identifier
    }
}

private struct GeoNamedPlace {
    let name: String
    let coordinate: GeoCoordinate
}
