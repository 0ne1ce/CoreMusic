import ImageIO
import SwiftUI
import UIKit

// @0ne1ce: For future improvements and usage in player and carousel
extension UIImage {
    static func downsampled(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        else {
            return nil
        }
        return UIImage(cgImage: thumbnail)
    }

    func dominantColors(sampleCount: Int = 1000) -> (primary: Color, secondary: Color) {
        guard let cgImage = self.cgImage else {
            return DominantColorsDefaults.fallback
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
        else {
            return DominantColorsDefaults.fallback
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var validPixels: [PixelRGB] = []
        var saturatedPixels: [PixelRGB] = []
        validPixels.reserveCapacity(sampleCount)
        saturatedPixels.reserveCapacity(sampleCount)

        for _ in 0..<sampleCount {
            let x = Int.random(in: 0..<width)
            let y = Int.random(in: 0..<height)
            let offset = y * bytesPerRow + x * bytesPerPixel
            let r = Float(pixelData[offset]) / 255
            let g = Float(pixelData[offset + 1]) / 255
            let b = Float(pixelData[offset + 2]) / 255

            let brightness = (r + g + b) / 3
            if brightness < FilterThresholds.minBrightness || brightness > FilterThresholds.maxBrightness {
                continue
            }
            let pixel = PixelRGB(r: r, g: g, b: b)
            validPixels.append(pixel)

            let saturation = max(r, g, b) - min(r, g, b)
            if saturation >= FilterThresholds.minSaturation {
                saturatedPixels.append(pixel)
            }
        }

        let pixels: [PixelRGB]
        if saturatedPixels.count >= FilterThresholds.minSaturatedPixels {
            pixels = saturatedPixels
        }
        else {
            pixels = validPixels.map { pixel in
                let gray = (pixel.r + pixel.g + pixel.b) / 3
                return PixelRGB(r: gray, g: gray, b: gray)
            }
        }

        guard pixels.count >= 2 else {
            return DominantColorsDefaults.fallback
        }

        var centroid1 = pixels[0]
        var centroid2 = pixels[pixels.count / 2]

        for _ in 0..<KMeans.iterations {
            var cluster1: [PixelRGB] = []
            var cluster2: [PixelRGB] = []

            for pixel in pixels {
                if pixel.distance(to: centroid1) < pixel.distance(to: centroid2) {
                    cluster1.append(pixel)
                }
                else {
                    cluster2.append(pixel)
                }
            }

            if !cluster1.isEmpty {
                centroid1 = PixelRGB.average(of: cluster1)
            }
            if !cluster2.isEmpty {
                centroid2 = PixelRGB.average(of: cluster2)
            }
        }

        let isCentroid1Brighter = centroid1.brightnessSum > centroid2.brightnessSum
        let primary = isCentroid1Brighter ? centroid1 : centroid2
        let secondary = isCentroid1Brighter ? centroid2 : centroid1

        return (primary: primary.color, secondary: secondary.color)
    }
}

// MARK: - Private types

private struct PixelRGB {
    let r: Float
    let g: Float
    let b: Float

    var brightnessSum: Float { r + g + b }

    var color: Color {
        Color(red: Double(r), green: Double(g), blue: Double(b))
    }

    func distance(to other: PixelRGB) -> Float {
        let dr = r - other.r
        let dg = g - other.g
        let db = b - other.b
        return sqrt(dr * dr + dg * dg + db * db)
    }

    static func average(of pixels: [PixelRGB]) -> PixelRGB {
        let count = Float(pixels.count)
        var sumR: Float = 0
        var sumG: Float = 0
        var sumB: Float = 0
        for pixel in pixels {
            sumR += pixel.r
            sumG += pixel.g
            sumB += pixel.b
        }
        return PixelRGB(r: sumR / count, g: sumG / count, b: sumB / count)
    }
}

private enum FilterThresholds {
    static let minBrightness: Float = 0.1
    static let maxBrightness: Float = 0.95
    static let minSaturation: Float = 0.15
    static let minSaturatedPixels: Int = 100
}

private enum KMeans {
    static let iterations: Int = 10
}

enum DominantColorsDefaults {
    static let fallback: (primary: Color, secondary: Color) = (.cmPrimaryLight, .cmPrimary)
}
