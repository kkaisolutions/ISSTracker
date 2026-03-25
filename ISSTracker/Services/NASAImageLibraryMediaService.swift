import Foundation

struct NASAImageLibraryMediaService: MediaProviding {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func loadMedia() async throws -> MediaPayload {
        let url = try makeSearchURL()
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        let searchResponse = try decoder.decode(NASAImageSearchResponse.self, from: data)
        let photos = searchResponse.collection.items
            .compactMap(\.spacePhoto)
            .sorted { $0.capturedAt > $1.capturedAt }

        guard let featuredPhoto = photos.first else {
            throw URLError(.cannotParseResponse)
        }

        return MediaPayload(
            featuredPhoto: featuredPhoto,
            recentPhotos: Array(photos.prefix(18)),
            liveFeeds: []
        )
    }

    private func makeSearchURL() throws -> URL {
        var components = URLComponents(string: "https://images-api.nasa.gov/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: "international space station earth"),
            URLQueryItem(name: "media_type", value: "image"),
            URLQueryItem(name: "page", value: "1")
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        return url
    }
}

private struct NASAImageSearchResponse: Decodable {
    let collection: NASACollection
}

private struct NASACollection: Decodable {
    let items: [NASACollectionItem]
}

private struct NASACollectionItem: Decodable {
    let data: [NASAItemMetadata]
    let links: [NASAItemLink]?

    var spacePhoto: SpacePhoto? {
        guard let metadata = data.first else { return nil }
        guard let imageURL = links?.first(where: { $0.render == "image" })?.href else { return nil }

        let title = metadata.title.nonEmpty ?? "ISS imagery"
        let caption = metadata.description?.nonEmpty ?? "Recent NASA imagery related to the International Space Station."

        return SpacePhoto(
            title: title,
            caption: caption,
            imageURL: imageURL,
            capturedAt: metadata.dateCreated,
            coordinateHint: nil
        )
    }
}

private struct NASAItemMetadata: Decodable {
    let title: String
    let description: String?
    let dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case dateCreated = "date_created"
    }
}

private struct NASAItemLink: Decodable {
    let href: URL
    let render: String?
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
