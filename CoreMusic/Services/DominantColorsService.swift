import Foundation
import MusicKit
import SwiftUI
import UIKit

protocol DominantColorsService: AnyObject, Sendable {
    func colors(for track: LibraryTrack) async -> (primary: Color, secondary: Color)
}

// @0ne1ce: for future improvements and usage in player and carousel
final class DominantColorsServiceImpl: DominantColorsService, @unchecked Sendable {
    // MARK: - Initializer

    init() {}

    // MARK: - Public methods

    func colors(for track: LibraryTrack) async -> (primary: Color, secondary: Color) {
        let key = track.id as NSString

        if let cached = cache.object(forKey: key) {
            return (cached.primary, cached.secondary)
        }

        guard let url = artworkURL(for: track) else {
            return DominantColorsDefaults.fallback
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let colors = await Task.detached(priority: .userInitiated) {
                guard let image = UIImage.downsampled(from: data, maxPixelSize: Constants.targetPixelSize) else {
                    return DominantColorsDefaults.fallback
                }
                return image.dominantColors()
            }.value

            cache.setObject(ColorPair(primary: colors.primary, secondary: colors.secondary), forKey: key)
            return colors
        }
        catch {
            return DominantColorsDefaults.fallback
        }
    }

    // MARK: - Private types

    private enum Constants {
        static let targetPixelSize: CGFloat = 100
    }

    // MARK: - Private properties

    private let cache = NSCache<NSString, ColorPair>()

    // MARK: - Private methods

    private func artworkURL(for track: LibraryTrack) -> URL? {
        if
            let artwork = track.artwork,
            let url = artwork.url(width: Int(Constants.targetPixelSize), height: Int(Constants.targetPixelSize))
        {
            return url
        }
        return track.artworkURL
    }
}

final class StubDominantColorsService: DominantColorsService, @unchecked Sendable {
    func colors(for track: LibraryTrack) async -> (primary: Color, secondary: Color) {
        DominantColorsDefaults.fallback
    }
}

// MARK: - Private types

private final class ColorPair {
    let primary: Color
    let secondary: Color

    init(primary: Color, secondary: Color) {
        self.primary = primary
        self.secondary = secondary
    }
}
