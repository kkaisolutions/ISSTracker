import Foundation

struct LiveFeed: Identifiable, Equatable {
    enum Status: String {
        case live = "Live now"
        case standby = "Standby"
        case unavailable = "Unavailable"
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let streamURL: URL?
    let status: Status
}

struct SpacePhoto: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let caption: String
    let imageURL: URL?
    let capturedAt: Date
    let coordinateHint: GeoCoordinate?
}

struct MediaPayload: Equatable {
    let featuredPhoto: SpacePhoto
    let recentPhotos: [SpacePhoto]
    let liveFeeds: [LiveFeed]
}
