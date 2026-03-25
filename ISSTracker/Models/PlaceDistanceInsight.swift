import Foundation

struct PlaceDistanceInsight: Equatable {
    let placeName: String
    let distanceKilometers: Double
    let countryCode: String?
    let coordinate: GeoCoordinate?

    var flag: String? {
        guard let countryCode else { return nil }
        return Self.flagEmoji(for: countryCode)
    }

    var flagAssetURL: URL? {
        guard let flag else { return nil }
        let codepoints = flag.unicodeScalars.map { String(format: "%x", $0.value) }.joined(separator: "-")
        return URL(string: "https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/\(codepoints).png")
    }

    var title: String {
        placeName
    }

    func updatingDistance(from coordinate: GeoCoordinate) -> PlaceDistanceInsight {
        PlaceDistanceInsight(
            placeName: placeName,
            distanceKilometers: self.coordinate.map { OrbitalInsights.haversineKilometers(from: coordinate, to: $0) } ?? distanceKilometers,
            countryCode: countryCode,
            coordinate: self.coordinate
        )
    }

    private static func flagEmoji(for countryCode: String) -> String? {
        let normalized = countryCode.uppercased()
        guard normalized.count == 2 else { return nil }

        let scalars = normalized.unicodeScalars.compactMap { scalar -> UnicodeScalar? in
            UnicodeScalar(127397 + scalar.value)
        }

        guard scalars.count == 2 else { return nil }
        return String(String.UnicodeScalarView(scalars))
    }
}
