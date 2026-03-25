import SwiftUI

struct MediaView: View {
    @ObservedObject var viewModel: MediaViewModel
    @Environment(\.dismiss) private var dismiss

    private var sortedPhotos: [SpacePhoto] {
        (viewModel.payload?.recentPhotos ?? []).sorted { $0.capturedAt > $1.capturedAt }
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            Group {
                if !sortedPhotos.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(sortedPhotos) { photo in
                                recentPhotoCard(photo)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 28)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    HUDCard {
                        Text(errorMessage)
                            .foregroundStyle(AppTheme.caution)
                    }
                    .padding(16)
                } else {
                    ProgressView("Loading latest images")
                        .tint(AppTheme.accent)
                        .foregroundStyle(.white)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            topBar
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
        .task {
            guard viewModel.payload == nil else { return }
            await viewModel.load()
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Latest images")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Most recent views from orbit")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Button("Done") {
                dismiss()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppTheme.glassHeavy, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.strokeStrong, lineWidth: 1)
            )
        }
    }

    private func recentPhotoCard(_ photo: SpacePhoto) -> some View {
        HUDCard {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.accentSecondary.opacity(0.62),
                                    AppTheme.backgroundTop,
                                    Color.black.opacity(0.88)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 190)
                        .overlay {
                            if let imageURL = photo.imageURL {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        fallbackImageSurface
                                    default:
                                        ZStack {
                                            fallbackImageSurface
                                            ProgressView()
                                                .tint(.white.opacity(0.85))
                                        }
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            } else {
                                fallbackImageSurface
                            }
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(photo.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)

                        Text(photo.capturedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .padding(18)
                }

                Text(photo.caption)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)

                if let coordinate = photo.coordinateHint {
                    Text(Formatters.coordinate(coordinate))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }

    private var fallbackImageSurface: some View {
        LinearGradient(
            colors: [
                AppTheme.accentSecondary.opacity(0.62),
                AppTheme.backgroundTop,
                Color.black.opacity(0.88)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    MediaView(viewModel: MediaViewModel(mediaProvider: MockMediaService()))
}
