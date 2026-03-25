import Foundation

struct MockMediaService: MediaProviding {
    func loadMedia() async throws -> MediaPayload {
        let featured = PreviewData.photos[0]

        return MediaPayload(
            featuredPhoto: featured,
            recentPhotos: PreviewData.photos,
            liveFeeds: PreviewData.liveFeeds
        )
    }
}
