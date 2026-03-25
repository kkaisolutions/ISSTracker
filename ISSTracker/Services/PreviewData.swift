import Foundation

enum PreviewData {
    static let liveFeeds: [LiveFeed] = [
        LiveFeed(
            title: "ISS Live Feed",
            subtitle: "Public stream window from orbit operations",
            streamURL: URL(string: "https://www.youtube.com/watch?v=DDU-rZs-Ic4"),
            status: .live
        ),
        LiveFeed(
            title: "Mission Audio",
            subtitle: "Crew-to-ground audio when available",
            streamURL: nil,
            status: .standby
        )
    ]

    static let photos: [SpacePhoto] = [
        SpacePhoto(
            title: "Blue Limb at Dawn",
            caption: "A cinematic orbital sunrise with the atmosphere glowing across the horizon.",
            imageURL: URL(string: "https://picsum.photos/seed/iss-dawn/1200/900"),
            capturedAt: .now.addingTimeInterval(-2_400),
            coordinateHint: GeoCoordinate(latitude: -11.0, longitude: 121.0)
        ),
        SpacePhoto(
            title: "Night Lights Over Europe",
            caption: "Dense city lights cutting through the terminator over the continent.",
            imageURL: URL(string: "https://picsum.photos/seed/iss-europe/1200/900"),
            capturedAt: .now.addingTimeInterval(-8_000),
            coordinateHint: GeoCoordinate(latitude: 51.0, longitude: 17.0)
        ),
        SpacePhoto(
            title: "Storm Structure in the Atlantic",
            caption: "A broad cloud spiral framed by the curvature of Earth.",
            imageURL: URL(string: "https://picsum.photos/seed/iss-atlantic/1200/900"),
            capturedAt: .now.addingTimeInterval(-18_000),
            coordinateHint: GeoCoordinate(latitude: 24.0, longitude: -48.0)
        )
    ]
}
