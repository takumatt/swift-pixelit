import CoreGraphics
import Foundation

extension PixelIt {
    public func convertPalette() -> PlatformImage? {
        guard let sourceImage = sourceImage,
              let cgImage = cgImage(from: sourceImage),
              let palette = palette else {
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
                let a = pixelData[pixelIndex + 3]
                
                let closestColor = findClosestColor(r: r, g: g, b: b, in: palette)
                
                pixelData[pixelIndex] = UInt8(closestColor.r)
                pixelData[pixelIndex + 1] = UInt8(closestColor.g)
                pixelData[pixelIndex + 2] = UInt8(closestColor.b)
                pixelData[pixelIndex + 3] = a
            }
        }
        
        guard let processedCGImage = context.makeImage() else {
            return nil
        }
        
        return platformImage(from: processedCGImage)
    }
    
    private func findClosestColor(r: Int, g: Int, b: Int, in palette: ColorPalette) -> (r: Int, g: Int, b: Int) {
        var closestDistance = Double.infinity
        var closestColor = (r: 0, g: 0, b: 0)
        
        for color in palette.colors {
            guard color.count >= 3 else { continue }
            
            let distance = colorDistance(
                r1: r, g1: g, b1: b,
                r2: color[0], g2: color[1], b2: color[2]
            )
            
            if distance < closestDistance {
                closestDistance = distance
                closestColor = (r: color[0], g: color[1], b: color[2])
            }
        }
        
        return closestColor
    }
    
    private func colorDistance(r1: Int, g1: Int, b1: Int, r2: Int, g2: Int, b2: Int) -> Double {
        let dr = Double(r1 - r2)
        let dg = Double(g1 - g2)
        let db = Double(b1 - b2)
        
        return sqrt(dr * dr + dg * dg + db * db)
    }
}