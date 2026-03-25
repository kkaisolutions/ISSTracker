import SwiftUI

struct TelemetryStrip: View {
    let telemetry: ISSTelemetry
    let nearestPlaceOverride: PlaceDistanceInsight?
    let nearestPlaceStatus: NearestPlaceStatus
    let telemetrySource: TelemetrySource
    let lastUpdatedAt: Date?
    let isRefreshing: Bool

    private var rigaInsight: PlaceDistanceInsight {
        OrbitalInsights.distanceToRiga(from: telemetry.coordinate)
    }

    private var headline: String {
        if let nearestPlaceOverride {
            return "ISS above \(nearestPlaceOverride.title)"
        }

        switch nearestPlaceStatus {
        case .idle, .resolving:
            return "Locating the nearest city"
        case .unavailable:
            return "Crossing a remote stretch of orbit"
        case .resolved:
            return "Tracking the ISS"
        }
    }

    private var subheadline: String {
        if let nearestPlaceOverride {
            return "\(Formatters.distanceKilometers(nearestPlaceOverride.distanceKilometers)) from the station"
        }

        switch nearestPlaceStatus {
        case .idle, .resolving:
            return "Place context is still resolving"
        case .unavailable:
            return "Nearest-place data is uncertain in this region"
        case .resolved:
            return "Live place context is available"
        }
    }

    private var contextualFact: LiveFact {
        if !telemetry.isVisibleToUser {
            return LiveFact(
                title: "Visibility",
                value: "Night side",
                systemImage: "moon.stars.fill"
            )
        }

        if telemetry.altitudeKilometers >= 430 {
            return LiveFact(
                title: "Altitude",
                value: Formatters.altitude(telemetry.altitudeKilometers),
                systemImage: "arrow.up.forward"
            )
        }

        return LiveFact(
            title: "Speed",
            value: Formatters.speed(telemetry.speedKilometersPerHour),
            systemImage: "gauge.with.needle"
        )
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let liveState = LiveStateDescriptor.make(
                telemetrySource: telemetrySource,
                lastUpdatedAt: lastUpdatedAt,
                isRefreshing: isRefreshing,
                now: context.date
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Live flight")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textTertiary)
                        .tracking(1.2)
                        .textCase(.uppercase)

                    Spacer()

                    Circle()
                        .fill(liveState.tint)
                        .frame(width: 8, height: 8)
                        .shadow(color: liveState.tint.opacity(0.6), radius: 4)
                }

                VStack(alignment: .leading, spacing: 6) {
                        if let nearestPlaceOverride {
                            HStack(alignment: .center, spacing: 8) {
                                Text("ISS above")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)

                                FlagImageView(place: nearestPlaceOverride, size: 22)

                                Text(nearestPlaceOverride.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        } else {
                            Text(headline)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(2)
                    }

                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    summaryChip(
                        title: liveState.title,
                        value: liveState.detail,
                        systemImage: liveState.systemImage,
                        tint: liveState.tint
                    )

                    summaryChip(
                        title: contextualFact.title,
                        value: contextualFact.value,
                        systemImage: contextualFact.systemImage,
                        tint: AppTheme.accent
                    )
                }

                HStack(spacing: 12) {
                    Label(
                        "Riga \(Formatters.distanceKilometers(rigaInsight.distanceKilometers)) away",
                        systemImage: "location.north.line"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)

                    Label("Live telemetry", systemImage: "waveform.path.ecg")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(AppTheme.panelGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(AppTheme.strokeStrong, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.32), radius: 24, y: 16)
        }
    }

    private func summaryChip(title: String, value: String, systemImage: String, tint: Color) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.stroke, lineWidth: 1)
        )
    }

}

private struct LiveFact {
    let title: String
    let value: String
    let systemImage: String
}

struct LiveStateDescriptor {
    let title: String
    let detail: String
    let systemImage: String
    let tint: Color

    static func make(
        telemetrySource: TelemetrySource,
        lastUpdatedAt: Date?,
        isRefreshing: Bool,
        now: Date
    ) -> LiveStateDescriptor {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short

        guard let lastUpdatedAt else {
            return LiveStateDescriptor(
                title: "Locking on",
                detail: "Awaiting telemetry",
                systemImage: "dot.radiowaves.left.and.right",
                tint: AppTheme.accent
            )
        }

        let age = now.timeIntervalSince(lastUpdatedAt)
        let relative = formatter.localizedString(for: lastUpdatedAt, relativeTo: now)

        if telemetrySource == .fallback {
            return LiveStateDescriptor(
                title: "Offline estimate",
                detail: "Updated \(relative)",
                systemImage: "antenna.radiowaves.left.and.right.slash",
                tint: AppTheme.caution
            )
        }

        if age > 12 {
            return LiveStateDescriptor(
                title: "Signal delayed",
                detail: "Updated \(relative)",
                systemImage: "exclamationmark.triangle.fill",
                tint: AppTheme.caution
            )
        }

        if isRefreshing {
            return LiveStateDescriptor(
                title: "Refreshing",
                detail: "Updated \(relative)",
                systemImage: "arrow.triangle.2.circlepath",
                tint: AppTheme.accent
            )
        }

        return LiveStateDescriptor(
            title: "Live orbit",
            detail: "Updated \(relative)",
            systemImage: "dot.radiowaves.left.and.right",
            tint: AppTheme.success
        )
    }
}

struct FlagImageView: View {
    let place: PlaceDistanceInsight
    let size: CGFloat

    var body: some View {
        if let url = place.flagAssetURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                default:
                    fallback
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: max(4, size * 0.18), style: .continuous))
        } else {
            fallback
        }
    }

    private var fallback: some View {
        Text(place.countryCode?.uppercased() ?? "??")
            .font(.caption2.weight(.bold))
            .foregroundStyle(AppTheme.textPrimary)
            .frame(width: size + 10, height: max(18, size * 0.78))
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )
    }
}
