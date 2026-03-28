import Foundation

struct OfflineCityRecord: Decodable {
    let n: String
    let cc: String
    let lat: Double
    let lon: Double
    let pop: Int

    var coordinate: GeoCoordinate {
        GeoCoordinate(latitude: lat, longitude: lon)
    }
}

enum OfflineCityIndex {
    private static let resourceName = "world-cities-liepaja-and-above"
    private static let resourceExtension = "json"

    static let shared: [OfflineCityRecord] = load()

    private static func load() -> [OfflineCityRecord] {
        guard let url = resourceURL() else {
            assertionFailure("Missing offline city index resource")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([OfflineCityRecord].self, from: data)
        } catch {
            assertionFailure("Failed to load offline city index: \(error)")
            return []
        }
    }

    private static func resourceURL() -> URL? {
        if let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) {
            return url
        }

        return Bundle(for: BundleLocator.self).url(forResource: resourceName, withExtension: resourceExtension)
    }
}

private final class BundleLocator {}
