import Foundation

struct LiveISSTelemetryService: ISSTelemetryProviding {
    private let decoder = JSONDecoder()

    func currentTelemetry() async throws -> TelemetrySnapshot {
        let fetchedAt = Date()

        do {
            return TelemetrySnapshot(
                telemetry: try await fetchLiveTelemetry(),
                source: .live,
                fetchedAt: fetchedAt
            )
        } catch {
            return TelemetrySnapshot(
                telemetry: fallbackTelemetry(at: fetchedAt),
                source: .fallback,
                fetchedAt: fetchedAt
            )
        }
    }

    private func fetchLiveTelemetry() async throws -> ISSTelemetry {
        let now = Date()
        let timestamps = stride(from: 0, through: 90 * 60, by: 10 * 60).map {
            String(Int(now.addingTimeInterval(TimeInterval($0)).timeIntervalSince1970))
        }.joined(separator: ",")

        async let currentResponse = fetch(CurrentISSResponse.self, from: "https://api.wheretheiss.at/v1/satellites/25544")
        async let positionsResponse = fetch([CurrentISSResponse].self, from: "https://api.wheretheiss.at/v1/satellites/25544/positions?timestamps=\(timestamps)")

        let current = try await currentResponse
        let positions = try await positionsResponse

        let currentCoordinate = GeoCoordinate(latitude: current.latitude, longitude: normalizeLongitude(current.longitude))
        let sunCoordinate = GeoCoordinate(latitude: current.solarLat, longitude: normalizeLongitude(current.solarLon))
        let allPoints = positions.map {
            OrbitPoint(coordinate: GeoCoordinate(latitude: $0.latitude, longitude: normalizeLongitude($0.longitude)))
        }

        return ISSTelemetry(
            timestamp: Date(timeIntervalSince1970: TimeInterval(current.timestamp)),
            coordinate: currentCoordinate,
            sunCoordinate: sunCoordinate,
            altitudeKilometers: current.altitude,
            speedKilometersPerHour: current.velocity,
            headingDegrees: inferredHeading(from: positions),
            orbitalPeriodMinutes: 93.01,
            inclinationDegrees: 51.6,
            footprintKilometers: current.footprint,
            nextSunrise: now.addingTimeInterval(current.visibility == "daylight" ? 45 * 60 : 12 * 60),
            nextSunset: now.addingTimeInterval(current.visibility == "daylight" ? 12 * 60 : 45 * 60),
            isVisibleToUser: current.visibility != "eclipsed",
            crewCount: 7,
            orbitNumber: 0,
            groundTrack: allPoints,
            groundTrackSegments: splitSegments(from: allPoints),
            nextPass: ISSPassPrediction(
                riseDate: now.addingTimeInterval(36 * 60),
                duration: 6 * 60,
                peakElevation: 68
            )
        )
    }

    private func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: URL(string: urlString)!)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(T.self, from: data)
    }

    private func inferredHeading(from positions: [CurrentISSResponse]) -> Double {
        guard positions.count >= 2 else { return 90 }
        let first = positions[0]
        let second = positions[1]
        let lat1 = first.latitude * .pi / 180
        let lat2 = second.latitude * .pi / 180
        let deltaLon = (second.longitude - first.longitude) * .pi / 180

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearing = atan2(y, x) * 180 / .pi
        return bearing >= 0 ? bearing : bearing + 360
    }

    private func splitSegments(from points: [OrbitPoint]) -> [[OrbitPoint]] {
        guard let first = points.first else { return [] }
        var segments: [[OrbitPoint]] = [[first]]

        for point in points.dropFirst() {
            guard let previous = segments.last?.last else { continue }
            let jump = abs(point.coordinate.longitude - previous.coordinate.longitude)
            if jump > 120 {
                segments.append([point])
            } else {
                segments[segments.count - 1].append(point)
            }
        }

        return segments.filter { $0.count > 1 }
    }

    private func fallbackTelemetry(at now: Date) -> ISSTelemetry {
        let coordinate = GeoCoordinate(latitude: -12.1, longitude: -106.8)
        let sunCoordinate = GeoCoordinate(latitude: 2.0, longitude: -54.0)
        let points = stride(from: -3_600, through: 5_400, by: 600).map { offset in
            OrbitPoint(
                coordinate: GeoCoordinate(
                    latitude: coordinate.latitude + Double(offset) / 1_800,
                    longitude: normalizeLongitude(coordinate.longitude + Double(offset) / 120)
                )
            )
        }

        return ISSTelemetry(
            timestamp: now,
            coordinate: coordinate,
            sunCoordinate: sunCoordinate,
            altitudeKilometers: 426.3,
            speedKilometersPerHour: 27_558,
            headingDegrees: 112,
            orbitalPeriodMinutes: 93.01,
            inclinationDegrees: 51.6,
            footprintKilometers: 4_260,
            nextSunrise: now.addingTimeInterval(22 * 60),
            nextSunset: now.addingTimeInterval(58 * 60),
            isVisibleToUser: true,
            crewCount: 7,
            orbitNumber: 0,
            groundTrack: points,
            groundTrackSegments: splitSegments(from: points),
            nextPass: ISSPassPrediction(
                riseDate: now.addingTimeInterval(36 * 60),
                duration: 6 * 60,
                peakElevation: 68
            )
        )
    }

    private func normalizeLongitude(_ longitude: Double) -> Double {
        var value = longitude
        while value > 180 { value -= 360 }
        while value < -180 { value += 360 }
        return value
    }
}

private struct CurrentISSResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let velocity: Double
    let visibility: String
    let footprint: Double
    let timestamp: Int
    let solarLat: Double
    let solarLon: Double

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case velocity
        case visibility
        case footprint
        case timestamp
        case solarLat = "solar_lat"
        case solarLon = "solar_lon"
    }
}

enum GroundTrackBuilder {
    static func build(around coordinate: GeoCoordinate) -> [OrbitPoint] {
        stride(from: -10, through: 10, by: 1).map { step in
            let longitude = normalizedLongitude(coordinate.longitude + Double(step) * 7.0)
            let latitude = max(-70, min(70, coordinate.latitude + Double(step) * 2.4))
            return OrbitPoint(coordinate: GeoCoordinate(latitude: latitude, longitude: longitude))
        }
    }

    static func buildSegments(around coordinate: GeoCoordinate) -> [[OrbitPoint]] {
        let points = build(around: coordinate)
        guard let first = points.first else { return [] }
        var segments: [[OrbitPoint]] = [[first]]

        for point in points.dropFirst() {
            guard let previous = segments.last?.last else { continue }
            if abs(point.coordinate.longitude - previous.coordinate.longitude) > 120 {
                segments.append([point])
            } else {
                segments[segments.count - 1].append(point)
            }
        }

        return segments.filter { $0.count > 1 }
    }

    private static func normalizedLongitude(_ longitude: Double) -> Double {
        var value = longitude
        while value > 180 { value -= 360 }
        while value < -180 { value += 360 }
        return value
    }
}
