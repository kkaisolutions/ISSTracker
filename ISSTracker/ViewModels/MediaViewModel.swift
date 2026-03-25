import Foundation

@MainActor
final class MediaViewModel: ObservableObject {
    @Published private(set) var payload: MediaPayload?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let mediaProvider: MediaProviding

    init(mediaProvider: MediaProviding) {
        self.mediaProvider = mediaProvider
    }

    func load(force: Bool = false) async {
        guard force || payload == nil else { return }

        isLoading = true
        defer { isLoading = false }

        if force {
            payload = nil
        }

        do {
            payload = try await mediaProvider.loadMedia()
            errorMessage = nil
        } catch {
            errorMessage = "Media is temporarily unavailable."
        }
    }
}
