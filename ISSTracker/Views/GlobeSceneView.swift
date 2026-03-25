import MapKit
import SwiftUI
import UIKit

struct GlobeSceneView: View {
    let telemetry: ISSTelemetry
    let nearestPlace: PlaceDistanceInsight?
    @Binding var followsISS: Bool
    let onUserExplore: () -> Void

    @State private var position: MapCameraPosition
    @State private var cameraDistance: CLLocationDistance = 8_000_000
    @State private var cameraPitch: CGFloat = 48
    @State private var cameraHeading: CLLocationDirection = 0

    private var interactionModes: MapInteractionModes {
        [.pan, .zoom, .pitch, .rotate]
    }

    init(
        telemetry: ISSTelemetry,
        nearestPlace: PlaceDistanceInsight?,
        followsISS: Binding<Bool>,
        onUserExplore: @escaping () -> Void = {}
    ) {
        self.telemetry = telemetry
        self.nearestPlace = nearestPlace
        _followsISS = followsISS
        self.onUserExplore = onUserExplore
        _position = State(initialValue: .camera(Self.camera(for: telemetry)))
    }

    var body: some View {
        ZStack {
            Map(position: $position, interactionModes: interactionModes) {
                ForEach(Array(telemetry.groundTrackSegments.enumerated()), id: \.offset) { _, segment in
                    MapPolyline(coordinates: segment.map(\.coordinate.locationCoordinate))
                        .stroke(
                            AppTheme.accent.opacity(0.74),
                            style: StrokeStyle(lineWidth: 0.4, lineCap: .round, lineJoin: .round, dash: [1.5, 8])
                        )
                }

                Annotation("Sun", coordinate: telemetry.sunCoordinate.locationCoordinate, anchor: .center) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 34, height: 34)

                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.yellow)
                    }
                }

                if let nearestPlace, let coordinate = nearestPlace.coordinate {
                    Annotation("", coordinate: coordinate.locationCoordinate, anchor: .center) {
                        Circle()
                            .fill(Color.red.opacity(0.92))
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }

                    Annotation(nearestPlace.title, coordinate: coordinate.locationCoordinate, anchor: .center) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            FlagImageView(place: nearestPlace, size: 18)

                            Text(nearestPlace.title)
                                .font(.caption.weight(.semibold))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.55), radius: 4, y: 2)
                        .offset(x: 0, y: 40)
                    }
                }

                Annotation(coordinate: telemetry.coordinate.locationCoordinate, anchor: .center) {
                    SatelliteAnnotationView()
                } label: {
                    Text("ISS")
                    }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .simultaneousGesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { _ in
                        guard followsISS else { return }
                        followsISS = false
                        onUserExplore()
                    }
            )
            .mapControls {
            }
            .onMapCameraChange(frequency: .continuous) { context in
                cameraDistance = context.camera.distance
                cameraPitch = context.camera.pitch
                cameraHeading = context.camera.heading
            }
            .onChange(of: telemetry.timestamp, initial: false) { _, _ in
                guard followsISS else { return }
                position = .camera(Self.camera(
                    for: telemetry,
                    distance: cameraDistance,
                    heading: cameraHeading,
                    pitch: cameraPitch
                ))
            }
            .onChange(of: followsISS, initial: false) { _, isFollowing in
                if isFollowing {
                    position = .camera(Self.camera(
                        for: telemetry,
                        distance: cameraDistance,
                        heading: cameraHeading,
                        pitch: cameraPitch
                    ))
                }
            }
        }
    }

    private static func camera(
        for telemetry: ISSTelemetry,
        distance: CLLocationDistance = 8_000_000,
        heading: CLLocationDirection? = nil,
        pitch: CGFloat = 48
    ) -> MapCamera {
        MapCamera(
            centerCoordinate: telemetry.coordinate.locationCoordinate,
            distance: max(distance, 200_000),
            heading: heading ?? telemetry.headingDegrees,
            pitch: pitch
        )
    }

}

private struct SatelliteAnnotationView: View {
    var body: some View {
        Image(uiImage: SatelliteMarkerRenderer.image)
            .resizable()
            .interpolation(.high)
            .frame(width: 28, height: 28)
            .shadow(color: AppTheme.accent.opacity(0.16), radius: 10, y: 4)
            .shadow(color: .black.opacity(0.22), radius: 6, y: 3)
        .accessibilityLabel("International Space Station")
    }
}

private enum SatelliteMarkerRenderer {
    static let image: UIImage = {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cg = context.cgContext
            cg.setAllowsAntialiasing(true)
            cg.setShouldAntialias(true)

            let stroke = UIColor.white.withAlphaComponent(0.96).cgColor
            let bodyFill = UIColor(red: 0.91, green: 0.94, blue: 0.98, alpha: 1.0).cgColor
            let bodyShade = UIColor(red: 0.77, green: 0.82, blue: 0.89, alpha: 1.0).cgColor
            let capFill = UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0).cgColor
            let panelFill = UIColor(red: 0.27, green: 0.63, blue: 0.98, alpha: 1.0).cgColor
            let panelShade = UIColor(red: 0.16, green: 0.44, blue: 0.78, alpha: 1.0).cgColor
            let mast = UIColor.white.withAlphaComponent(0.85).cgColor
            let accent = UIColor(red: 1.0, green: 0.34, blue: 0.28, alpha: 1.0).cgColor

            cg.setLineWidth(2.2)
            cg.setLineCap(.round)
            cg.setStrokeColor(stroke)

            cg.saveGState()
            cg.translateBy(x: size.width / 2, y: size.height / 2)
            cg.rotate(by: -.pi / 5)

            cg.setStrokeColor(mast)
            cg.setLineWidth(2)
            cg.move(to: CGPoint(x: -18, y: 0))
            cg.addLine(to: CGPoint(x: 18, y: 0))
            cg.strokePath()

            cg.setFillColor(bodyFill)
            let body = UIBezierPath(roundedRect: CGRect(x: -8, y: -14, width: 16, height: 28), cornerRadius: 7)
            cg.addPath(body.cgPath)
            cg.drawPath(using: .fillStroke)

            cg.setFillColor(bodyShade)
            cg.fill(CGRect(x: -5, y: -7, width: 10, height: 14))

            cg.setFillColor(panelFill)
            for x in stride(from: -29.0, through: -17.0, by: 6.0) {
                let panel = UIBezierPath(roundedRect: CGRect(x: x, y: -11, width: 5, height: 10), cornerRadius: 1.8)
                cg.addPath(panel.cgPath)
                cg.drawPath(using: .fillStroke)
            }
            for x in stride(from: 12.0, through: 24.0, by: 6.0) {
                let panel = UIBezierPath(roundedRect: CGRect(x: x, y: 1, width: 5, height: 10), cornerRadius: 1.8)
                cg.addPath(panel.cgPath)
                cg.drawPath(using: .fillStroke)
            }

            cg.setFillColor(panelShade)
            cg.fill(CGRect(x: -28, y: -7, width: 14, height: 2.6))
            cg.fill(CGRect(x: 13, y: 5, width: 14, height: 2.6))

            cg.setStrokeColor(stroke)
            cg.move(to: CGPoint(x: 2, y: -15))
            cg.addLine(to: CGPoint(x: 11, y: -22))
            cg.strokePath()

            cg.setFillColor(capFill)
            let dish = UIBezierPath(ovalIn: CGRect(x: 8, y: -25, width: 14, height: 10))
            cg.saveGState()
            cg.translateBy(x: 15, y: -20)
            cg.rotate(by: .pi / 8)
            cg.translateBy(x: -15, y: 20)
            cg.addPath(dish.cgPath)
            cg.drawPath(using: .fillStroke)
            cg.restoreGState()

            cg.setFillColor(accent)
            cg.fillEllipse(in: CGRect(x: 19, y: -24, width: 4.5, height: 4.5))

            cg.restoreGState()
        }
    }()
}

#Preview {
    GlobeSceneView(telemetry: PreviewTelemetry.sample(), nearestPlace: nil, followsISS: .constant(true))
        .frame(height: 380)
        .background(AppTheme.background)
}
