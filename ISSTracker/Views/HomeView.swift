import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var mediaViewModel: MediaViewModel
    @State private var showingMediaFeed = false
    @State private var followsISS = true

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if let telemetry = viewModel.telemetry {
                    GlobeSceneView(
                        telemetry: telemetry,
                        nearestPlace: viewModel.nearestPlaceInsight,
                        followsISS: $followsISS,
                        onUserExplore: {}
                    )
                    .ignoresSafeArea()

                    overlayGradients

                    VStack(spacing: 14) {
                        topStatusOverlay
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 52)
                    .ignoresSafeArea(edges: .top)
                    .zIndex(2)
                } else {
                    loadingStateView
                }
            }
            .fullScreenCover(isPresented: $showingMediaFeed) {
                MediaView(viewModel: mediaViewModel)
            }
            .safeAreaInset(edge: .bottom) {
                if let telemetry = viewModel.telemetry {
                    TelemetryStrip(
                        telemetry: telemetry,
                        nearestPlaceOverride: viewModel.nearestPlaceInsight,
                        nearestPlaceStatus: viewModel.nearestPlaceStatus,
                        telemetrySource: viewModel.telemetrySource,
                        lastUpdatedAt: viewModel.lastUpdatedAt,
                        isRefreshing: viewModel.isRefreshing
                    )
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                }
            }
            .onChange(of: scenePhase, initial: true) { _, newPhase in
                switch newPhase {
                case .active:
                    viewModel.start()
                default:
                    viewModel.stop()
                }
            }
            .onDisappear {
                viewModel.stop()
            }
        }
    }

    private var overlayGradients: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black.opacity(0.6), .clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.12), Color.black.opacity(0.74)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }

    private var topStatusOverlay: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ISS Tracker")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textTertiary)
                .tracking(1.4)
                .textCase(.uppercase)

            TimelineView(.periodic(from: .now, by: 1)) { context in
                HStack(alignment: .top, spacing: 8) {
                    statusCapsule(for: liveState(at: context.date))
                    modeCapsule
                    detailsButton
                }
            }
        }
    }

    private var detailsButton: some View {
        Button {
            showingMediaFeed = true
        } label: {
            VStack(spacing: 5) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 15, weight: .semibold))
                Text("Details")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(AppTheme.textPrimary)
            .frame(width: 82, height: 56)
            .background(AppTheme.glass, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.strokeStrong, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("Open the latest images from orbit")
    }

    private var modeCapsule: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                followsISS.toggle()
            }
        } label: {
            Label(followsISS ? "Auto-follow" : "Exploring map", systemImage: followsISS ? "scope" : "hand.draw.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 128, height: 56)
                .background(AppTheme.glass, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.strokeStrong, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityHint(followsISS ? "Switch to manual map exploration" : "Recenter and follow the ISS")
    }

    private var loadingStateView: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                    .tint(AppTheme.accent)

                Text("Locking onto the ISS")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Bringing in live telemetry and orbital context.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(28)
            .background(AppTheme.glassHeavy, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.panelGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )
        }
    }

    private func liveState(at now: Date) -> LiveStateDescriptor {
        LiveStateDescriptor.make(
            telemetrySource: viewModel.telemetrySource,
            lastUpdatedAt: viewModel.lastUpdatedAt,
            isRefreshing: viewModel.isRefreshing,
            now: now
        )
    }

    private func statusCapsule(for state: LiveStateDescriptor) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(state.title, systemImage: state.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(state.detail)
                .font(.caption2)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 56)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.glass, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(state.tint.opacity(0.45), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            telemetryProvider: LiveISSTelemetryService(),
            nearestPlaceResolver: NearestPlaceResolver()
        ),
        mediaViewModel: MediaViewModel(mediaProvider: MockMediaService())
    )
}
