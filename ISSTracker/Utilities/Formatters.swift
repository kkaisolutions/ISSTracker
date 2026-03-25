import Foundation

enum Formatters {
    static func altitude(_ value: Double) -> String {
        "\(Int(value.rounded())) km"
    }

    static func speed(_ value: Double) -> String {
        "\(Int(value.rounded())) km/h"
    }

    static func heading(_ value: Double) -> String {
        "\(Int(value.rounded())) degrees"
    }

    static func duration(minutes: Double) -> String {
        let totalMinutes = Int(minutes.rounded())
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }

    static func coordinate(_ value: GeoCoordinate) -> String {
        let lat = String(format: "%.1f", abs(value.latitude))
        let lon = String(format: "%.1f", abs(value.longitude))
        let latHemisphere = value.latitude >= 0 ? "N" : "S"
        let lonHemisphere = value.longitude >= 0 ? "E" : "W"
        return "\(lat) \(latHemisphere), \(lon) \(lonHemisphere)"
    }

    static func distanceKilometers(_ value: Double) -> String {
        "\(Int(value.rounded())) km"
    }
}
