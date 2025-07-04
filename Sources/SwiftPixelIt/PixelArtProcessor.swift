import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

public struct PixelArtConfiguration {
    public let pixelSize: Int
    public let maxSize: CGSize?
    public let colorPalette: ColorPalette?
    
    public init(
        pixelSize: Int = 8,
        maxSize: CGSize? = nil,
        colorPalette: ColorPalette? = nil
    ) {
        self.pixelSize = max(1, min(50, pixelSize))
        self.maxSize = maxSize
        self.colorPalette = colorPalette
    }
    
    public static let `default` = PixelArtConfiguration()
}

public struct ColorPalette {
    public let colors: [Color]
    
    public init(colors: [Color]) {
        self.colors = colors
    }
    
    public init(rgbColors: [[Int]]) {
        self.colors = rgbColors.compactMap { rgb in
            guard rgb.count >= 3 else { return nil }
            return Color(red: rgb[0], green: rgb[1], blue: rgb[2])
        }
    }
    
    public static let retro = ColorPalette(rgbColors: [
        [26, 28, 44],
        [93, 39, 93],
        [177, 62, 83],
        [238, 108, 77],
        [255, 205, 117],
        [167, 219, 216],
        [68, 137, 26],
        [45, 45, 45],
        [255, 255, 255]
    ])
    
    public static let gameboy = ColorPalette(rgbColors: [
        [15, 56, 15],
        [48, 98, 48],
        [139, 172, 15],
        [155, 188, 15]
    ])
}

public struct Color {
    public let red: Int
    public let green: Int
    public let blue: Int
    
    public init(red: Int, green: Int, blue: Int) {
        self.red = max(0, min(255, red))
        self.green = max(0, min(255, green))
        self.blue = max(0, min(255, blue))
    }
}

public struct PixelArtProcessor {
    
    public init() {}
    
    public func pixelate(
        _ image: PlatformImage,
        using configuration: PixelArtConfiguration = .default
    ) -> PlatformImage? {
        guard let cgImage = cgImage(from: image) else { return nil }
        
        let resizedImage = resizeIfNeeded(cgImage, maxSize: configuration.maxSize)
        let pixelatedImage = applyPixelation(resizedImage, pixelSize: configuration.pixelSize)
        
        return platformImage(from: pixelatedImage)
    }
    
    public func applyPalette(
        _ image: PlatformImage,
        palette: ColorPalette
    ) -> PlatformImage? {
        guard let cgImage = cgImage(from: image) else { return nil }
        let processedImage = convertToPalette(cgImage, palette: palette)
        return platformImage(from: processedImage)
    }
    
    public func convertToGrayscale(_ image: PlatformImage) -> PlatformImage? {
        guard let cgImage = cgImage(from: image) else { return nil }
        let grayscaleImage = applyGrayscaleFilter(cgImage)
        return platformImage(from: grayscaleImage)
    }
    
    public func processPixelArt(
        _ image: PlatformImage,
        configuration: PixelArtConfiguration
    ) -> PlatformImage? {
        guard let pixelatedImage = pixelate(image, using: configuration) else {
            return nil
        }
        
        if let palette = configuration.colorPalette {
            return applyPalette(pixelatedImage, palette: palette)
        }
        
        return pixelatedImage
    }
}

// MARK: - Internal Implementation
extension PixelArtProcessor {
    
    private func cgImage(from image: PlatformImage) -> CGImage? {
        #if canImport(UIKit)
        return image.cgImage
        #elseif canImport(AppKit)
        var proposedRect = NSRect.zero
        return image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
        #endif
    }
    
    private func platformImage(from cgImage: CGImage) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(cgImage: cgImage)
        #elseif canImport(AppKit)
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        #endif
    }
    
    private func resizeIfNeeded(_ image: CGImage, maxSize: CGSize?) -> CGImage {
        guard let maxSize = maxSize else { return image }
        
        let originalWidth = image.width
        let originalHeight = image.height
        
        let scaleX = maxSize.width / CGFloat(originalWidth)
        let scaleY = maxSize.height / CGFloat(originalHeight)
        let scale = min(scaleX, scaleY, 1.0)
        
        if scale >= 1.0 { return image }
        
        let newWidth = Int(CGFloat(originalWidth) * scale)
        let newHeight = Int(CGFloat(originalHeight) * scale)
        
        return resizeImage(image, to: CGSize(width: newWidth, height: newHeight)) ?? image
    }
    
    private func resizeImage(_ image: CGImage, to size: CGSize) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: size))
        
        return context.makeImage()
    }
    
    private func applyPixelation(_ image: CGImage, pixelSize: Int) -> CGImage {
        let width = image.width
        let height = image.height
        
        let pixelWidth = width / pixelSize
        let pixelHeight = height / pixelSize
        
        guard pixelWidth > 0, pixelHeight > 0 else { return image }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        // Create small version
        guard let pixelContext = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return image }
        
        pixelContext.interpolationQuality = CGInterpolationQuality.none
        pixelContext.draw(image, in: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        
        guard let pixelatedSmall = pixelContext.makeImage() else { return image }
        
        // Scale back up
        guard let finalContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return image }
        
        finalContext.interpolationQuality = CGInterpolationQuality.none
        finalContext.draw(pixelatedSmall, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return finalContext.makeImage() ?? image
    }
    
    private func convertToPalette(_ image: CGImage, palette: ColorPalette) -> CGImage {
        let width = image.width
        let height = image.height
        
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
        ) else { return image }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return image }
        
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
                
                pixelData[pixelIndex] = UInt8(closestColor.red)
                pixelData[pixelIndex + 1] = UInt8(closestColor.green)
                pixelData[pixelIndex + 2] = UInt8(closestColor.blue)
                pixelData[pixelIndex + 3] = a
            }
        }
        
        return context.makeImage() ?? image
    }
    
    private func applyGrayscaleFilter(_ image: CGImage) -> CGImage {
        let width = image.width
        let height = image.height
        
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
        ) else { return image }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return image }
        
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
        
        return context.makeImage() ?? image
    }
    
    private func findClosestColor(r: Int, g: Int, b: Int, in palette: ColorPalette) -> Color {
        var closestDistance = Double.infinity
        var closestColor = Color(red: 0, green: 0, blue: 0)
        
        for color in palette.colors {
            let distance = colorDistance(
                r1: r, g1: g, b1: b,
                r2: color.red, g2: color.green, b2: color.blue
            )
            
            if distance < closestDistance {
                closestDistance = distance
                closestColor = color
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