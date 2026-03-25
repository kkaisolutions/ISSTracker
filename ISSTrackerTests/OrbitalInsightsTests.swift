import XCTest
@testable import ISSTracker

final class OrbitalInsightsTests: XCTestCase {
    func testDistanceToRigaUsesLatviaCountryCode() {
        let result = OrbitalInsights.distanceToRiga(from: GeoCoordinate(latitude: 56.9496, longitude: 24.1052))
        XCTAssertEqual(result.countryCode, "LV")
        XCTAssertEqual(result.flag, "🇱🇻")
    }

    func testPlaceDistanceInsightSeparatesPlainTitleAndFlag() {
        let insight = PlaceDistanceInsight(
            placeName: "Al Malha, Sudan",
            distanceKilometers: 219,
            countryCode: "SD",
            coordinate: GeoCoordinate(latitude: 14.0, longitude: 24.0)
        )

        XCTAssertEqual(insight.title, "Al Malha, Sudan")
        XCTAssertEqual(insight.flag, "🇸🇩")
    }

    func testHaversineDistanceIsZeroForSameCoordinate() {
        let coordinate = GeoCoordinate(latitude: 10, longitude: 20)
        XCTAssertEqual(OrbitalInsights.haversineKilometers(from: coordinate, to: coordinate), 0, accuracy: 0.0001)
    }
}
