import XCTest
@testable import ISSTracker

final class FormatterTests: XCTestCase {
    func testCoordinateFormattingUsesCardinalDirections() {
        let result = Formatters.coordinate(GeoCoordinate(latitude: -12.3, longitude: 44.9))
        XCTAssertEqual(result, "12.3 S, 44.9 E")
    }

    func testDurationFormattingUsesHoursWhenNeeded() {
        let result = Formatters.duration(minutes: 92.6)
        XCTAssertEqual(result, "1h 33m")
    }
}
