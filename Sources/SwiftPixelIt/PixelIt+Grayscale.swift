import CoreGraphics
import Foundation

extension PixelIt {
    public func convertGrayscale() -> PlatformImage? {
        guard let sourceImage = sourceImage,
              let cgImage = cgImage(from: sourceImage) else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            return nil
        }
        
        let bytesPerPixel = 4
        let bytesPerRow = context.bytesPerRow
        let pixelData = data.bindMemory(to: UInt8.self, capacity: height * bytesPerRow)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * bytesPerRow + x * bytesPerPixel
                
                let r = Int(pixelData[pixelIndex])
                let g = Int(pixelData[pixelIndex + 1])
                let b = Int(pixelData[pixelIndex + 2])
                
                let gray = UInt8((r + g + b) / 3)
                
                pixelData[pixelIndex] = gray
                pixelData[pixelIndex + 1] = gray
                pixelData[pixelIndex + 2] = gray
            }
        }
        
        guard let grayscaleCGImage = context.makeImage() else {
            return nil
        }
        
        return platformImage(from: grayscaleCGImage)
    }
}