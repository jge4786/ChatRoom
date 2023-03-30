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
    
    @discardableResult
    func saveImageToCache(image: UIImage, id: Int) -> NSAttributedString {
        let resizedImage = resized(image: image, to: CGSize(width: Constants.imageSize, height: Constants.imageSize))
        
//        let scale = (Constants.deviceSize.width * Constants.chatMaxWidthMultiplier) / image.size.width
//
//
//
//        let resizedImage = resizeByScale(image: image, by: scale < 1.0 ? scale : 1.0)
        
        
        let attachment = NSTextAttachment()
        attachment.image = resizedImage
        let imageString = NSAttributedString(attachment: attachment)
        
        imageDataCache.setObject(resizedImage, forKey: NSString(string: String(id)))
        imageCache.setObject(imageString, forKey: NSString(string: String(id)))
        
        return imageString
    }
}
