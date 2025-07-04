import SwiftPixelIt

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class BasicUsageExample {
    func pixelateImage(_ image: PlatformImage) -> PlatformImage? {
        let pixelIt = PixelIt(from: image)
        return pixelIt
            .setScale(8)
            .setMaxWidth(300)
            .setMaxHeight(300)
            .pixelate()
    }
    
    func applyCustomPalette(_ image: PlatformImage) -> PlatformImage? {
        let retroPalette = ColorPalette(colors: [
            [26, 28, 44],   // Dark blue
            [93, 39, 93],   // Purple
            [177, 62, 83],  // Pink
            [238, 108, 77], // Orange
            [255, 205, 117] // Yellow
        ])
        
        let pixelIt = PixelIt(from: image)
        return pixelIt
            .setScale(6)
            .setPalette(retroPalette)
            .pixelate()
    }
    
    func createGrayscalePixelArt(_ image: PlatformImage) -> PlatformImage? {
        let pixelIt = PixelIt(from: image)
        return pixelIt
            .setScale(10)
            .convertGrayscale()
    }
    
    func fullProcessingPipeline(_ image: PlatformImage) -> PlatformImage? {
        let pixelIt = PixelIt(from: image)
        
        let processedImage = pixelIt
            .setScale(8)
            .setMaxWidth(200)
            .setMaxHeight(200)
            .pixelate()
        
        guard let pixelatedImage = processedImage else {
            return nil
        }
        
        return PixelIt(from: pixelatedImage)
            .setPalette(ColorPalette.defaultPalette)
            .convertPalette()
    }
}