import XCTest
@testable import ISSTracker

final class FormattersTests: XCTestCase {
    func testDurationFormatsHoursAndMinutes() {
        XCTAssertEqual(Formatters.duration(minutes: 93.01), "1h 33m")
    }

    func testCoordinateFormatsHemisphereSuffixes() {
        let coordinate = GeoCoordinate(latitude: 56.95, longitude: -24.11)
        XCTAssertEqual(Formatters.coordinate(coordinate), "57.0 N, 24.1 W")
    }

    func testDistanceRoundsToNearestKilometer() {
        XCTAssertEqual(Formatters.distanceKilometers(425.6), "426 km")
    }
}
