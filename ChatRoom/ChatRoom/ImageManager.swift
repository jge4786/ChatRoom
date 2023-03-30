//import Foundation
import UIKit

class ImageManager {
    public static let shared = ImageManager()
    
    private init() {}
    
    public var imageCache = NSCache<NSString, NSAttributedString>()
    
    func resized(image: UIImage, to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resizeByScale(image: UIImage, by value: Double) -> UIImage {
        let targetSize = CGSize(width: image.size.width * value, height: image.size.height * value)
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
