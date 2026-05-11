import UIKit

extension UIImage {
    //@0ne1ce: compress photo if I decide to switch from
    // firestorage (need paid plan) to firestore (free, but low quality)
    static func cm_compress(data: Data, maxDimension: CGFloat = 1200, quality: CGFloat = 0.7) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)

        guard scale < 1.0 else {
            return image.jpegData(compressionQuality: quality)
        }

        let targetSize = CGSize(
            width: (image.size.width * scale).rounded(.down),
            height: (image.size.height * scale).rounded(.down)
        )

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized.jpegData(compressionQuality: quality)
    }
}
