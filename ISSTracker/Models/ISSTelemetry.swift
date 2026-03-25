import Foundation
import CoreLocation

enum TelemetrySource: Equatable {
    case live
    case fallback
}

struct TelemetrySnapshot: Equatable {
    let telemetry: ISSTelemetry
    let source: TelemetrySource
    let fetchedAt: Date
}

struct GeoCoordinate: Equatable {
    let latitude: Double
    let longitude: Double

    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct OrbitPoint: Identifiable, Equatable {
    let id = UUID()
    let coordinate: GeoCoordinate
}

struct ISSPassPrediction: Identifiable, Equatable {
    let id = UUID()
    let riseDate: Date
    let duration: TimeInterval
    let peakElevation: Double
}

struct ISSTelemetry: Equatable {
    let timestamp: Date
    let coordinate: GeoCoordinate
    let sunCoordinate: GeoCoordinate
    let altitudeKilometers: Double
    let speedKilometersPerHour: Double
    let headingDegrees: Double
    let orbitalPeriodMinutes: Double
    let inclinationDegrees: Double
    let footprintKilometers: Double
    let nextSunrise: Date
    let nextSunset: Date
    let isVisibleToUser: Bool
    let crewCount: Int
    let orbitNumber: Int
    let groundTrack: [OrbitPoint]
    let groundTrackSegments: [[OrbitPoint]]
    let nextPass: ISSPassPrediction
}

enum PreviewTelemetry {
    static func sample() -> ISSTelemetry {
        let coordinate = GeoCoordinate(latitude: 18.4, longitude: -124.6)
        return ISSTelemetry(
            timestamp: .now,
            coordinate: coordinate,
            sunCoordinate: GeoCoordinate(latitude: -4.0, longitude: -52.0),
            altitudeKilometers: 419.0,
            speedKilometersPerHour: 27_580,
            headingDegrees: 108.4,
            orbitalPeriodMinutes: 92.6,
            inclinationDegrees: 51.6,
            footprintKilometers: 4_420,
            nextSunrise: .now.addingTimeInterval(15 * 60),
            nextSunset: .now.addingTimeInterval(64 * 60),
            isVisibleToUser: true,
            crewCount: 7,
            orbitNumber: 141_224,
            groundTrack: GroundTrackBuilder.build(around: coordinate),
            groundTrackSegments: GroundTrackBuilder.buildSegments(around: coordinate),
            nextPass: ISSPassPrediction(
                riseDate: .now.addingTimeInterval(36 * 60),
                duration: 6 * 60,
                peakElevation: 68
            )
        )
    }
}
