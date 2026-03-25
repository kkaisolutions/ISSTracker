import Foundation

@MainActor
final class MediaViewModel: ObservableObject {
    @Published private(set) var payload: MediaPayload?
    @Published private(set) var errorMessage: String?

    private let mediaProvider: MediaProviding

    init(mediaProvider: MediaProviding) {
        self.mediaProvider = mediaProvider
    }

    func load() async {
        do {
            payload = try await mediaProvider.loadMedia()
            errorMessage = nil
        } catch {
            errorMessage = "Media is temporarily unavailable."
        }
    }
}
