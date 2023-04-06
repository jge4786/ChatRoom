//import Foundation
import UIKit

final class ImageManager {
    public static let shared = ImageManager()
    
    private init() {}
    
    public var imageCache = NSCache<NSString, NSAttributedString>()
    public var imageDataCache = NSCache<NSString, UIImage>()
    
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
    
    func getFitSize(image: UIImage) -> CGSize {
        let deviceSize = UIScreen.main.bounds.size
        
        let maxWidth = deviceSize.width * Constants.chatMaxWidthMultiplier
        
        var ratio = maxWidth / image.size.width
        ratio = ratio > 1 ? 1 : ratio
        
        return CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
    }
    
    @discardableResult
    func saveImageToCache(image: UIImage, id: Int) -> UIImage {
        let resizedImage = resized(image: image, to: getFitSize(image: image))
        
        imageDataCache.setObject(resizedImage, forKey: NSString(string: String(id)))
        
        return resizedImage
    }
}
