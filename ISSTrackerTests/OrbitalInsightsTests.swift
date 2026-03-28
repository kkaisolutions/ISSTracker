import XCTest
@testable import ISSTracker

final class OrbitalInsightsTests: XCTestCase {
    func testDistanceToRigaUsesLatviaCountryCode() {
        let insight = OrbitalInsights.distanceToRiga(
            from: GeoCoordinate(latitude: 56.9496, longitude: 24.1052)
        )

        XCTAssertEqual(insight.countryCode, "LV")
        XCTAssertEqual(insight.distanceKilometers, 0, accuracy: 0.01)
    }

    func testSettlementSearchCoordinatesExpandsPredictably() {
        let coordinates = OrbitalInsights.settlementSearchCoordinates(
            from: GeoCoordinate(latitude: 0, longitude: 0)
        )

        XCTAssertEqual(coordinates.count, 41)
        XCTAssertEqual(coordinates.first?.latitude, 0)
        XCTAssertEqual(coordinates.first?.longitude, 0)
    }

    func testHaversineDistanceIsSymmetric() {
        let a = GeoCoordinate(latitude: 56.9496, longitude: 24.1052)
        let b = GeoCoordinate(latitude: 40.7128, longitude: -74.0060)

        let forward = OrbitalInsights.haversineKilometers(from: a, to: b)
        let backward = OrbitalInsights.haversineKilometers(from: b, to: a)

        XCTAssertEqual(forward, backward, accuracy: 0.001)
    }
}
