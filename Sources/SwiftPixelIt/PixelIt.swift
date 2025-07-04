import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

public struct ColorPalette {
    public let colors: [[Int]]
    
    public init(colors: [[Int]]) {
        self.colors = colors
    }
    
    public static let defaultPalette: ColorPalette = ColorPalette(colors: [
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
}

public class PixelIt {
    internal var sourceImage: PlatformImage?
    internal var scale: Int = 8
    internal var palette: ColorPalette?
    internal var maxWidth: Int?
    internal var maxHeight: Int?
    
    public init(from image: PlatformImage? = nil, palette: ColorPalette? = nil) {
        self.sourceImage = image
        self.palette = palette
    }
    
    public func setScale(_ scale: Int) -> PixelIt {
        self.scale = max(1, min(50, scale))
        return self
    }
    
    public func setPalette(_ palette: ColorPalette) -> PixelIt {
        self.palette = palette
        return self
    }
    
    public func setMaxWidth(_ width: Int) -> PixelIt {
        self.maxWidth = width
        return self
    }
    
    public func setMaxHeight(_ height: Int) -> PixelIt {
        self.maxHeight = height
        return self
    }
    
    public func setSource(_ image: PlatformImage) -> PixelIt {
        self.sourceImage = image
        return self
    }
}

extension PixelIt {
    internal func cgImage(from image: PlatformImage) -> CGImage? {
        #if canImport(UIKit)
        return image.cgImage
        #elseif canImport(AppKit)
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }
    
    internal func platformImage(from cgImage: CGImage) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(cgImage: cgImage)
        #elseif canImport(AppKit)
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        #endif
    }
}