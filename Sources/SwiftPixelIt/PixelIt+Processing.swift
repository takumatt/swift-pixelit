import CoreGraphics
import Foundation

extension PixelIt {
    public func pixelate() -> PlatformImage? {
        guard let sourceImage = sourceImage,
              let cgImage = cgImage(from: sourceImage) else {
            return nil
        }
        
        let originalWidth = cgImage.width
        let originalHeight = cgImage.height
        
        let resizedSize = calculateResizedSize(
            originalWidth: originalWidth,
            originalHeight: originalHeight
        )
        
        let pixelWidth = resizedSize.width / scale
        let pixelHeight = resizedSize.height / scale
        
        guard pixelWidth > 0, pixelHeight > 0 else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let pixelContext = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        pixelContext.interpolationQuality = CGInterpolationQuality.none
        pixelContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        
        guard let pixelatedCGImage = pixelContext.makeImage() else {
            return nil
        }
        
        guard let finalContext = CGContext(
            data: nil,
            width: resizedSize.width,
            height: resizedSize.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        finalContext.interpolationQuality = CGInterpolationQuality.none
        finalContext.draw(pixelatedCGImage, in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        
        guard let finalCGImage = finalContext.makeImage() else {
            return nil
        }
        
        return platformImage(from: finalCGImage)
    }
    
    internal func calculateResizedSize(originalWidth: Int, originalHeight: Int) -> (width: Int, height: Int) {
        var width = originalWidth
        var height = originalHeight
        
        if let maxWidth = maxWidth, width > maxWidth {
            let ratio = Double(maxWidth) / Double(width)
            width = maxWidth
            height = Int(Double(height) * ratio)
        }
        
        if let maxHeight = maxHeight, height > maxHeight {
            let ratio = Double(maxHeight) / Double(height)
            height = maxHeight
            width = Int(Double(width) * ratio)
        }
        
        return (width: width, height: height)
    }
}