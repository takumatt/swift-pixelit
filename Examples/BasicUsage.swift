import SwiftPixelIt

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class BasicUsageExamples {
    
    private let processor = PixelArtProcessor()
    
    func basicPixelation(_ image: PlatformImage) -> PlatformImage? {
        let config = PixelArtConfiguration(pixelSize: 8)
        return processor.pixelate(image, using: config)
    }
    
    func pixelateWithSizeLimit(_ image: PlatformImage) -> PlatformImage? {
        let config = PixelArtConfiguration(
            pixelSize: 10,
            maxSize: CGSize(width: 300, height: 300)
        )
        return processor.pixelate(image, using: config)
    }
    
    func applyRetroStyle(_ image: PlatformImage) -> PlatformImage? {
        let config = PixelArtConfiguration(
            pixelSize: 8,
            colorPalette: .retro
        )
        return processor.processPixelArt(image, configuration: config)
    }
    
    func applyGameboyStyle(_ image: PlatformImage) -> PlatformImage? {
        let config = PixelArtConfiguration(
            pixelSize: 12,
            colorPalette: .gameboy
        )
        return processor.processPixelArt(image, configuration: config)
    }
    
    func createCustomPalette(_ image: PlatformImage) -> PlatformImage? {
        let customPalette = ColorPalette(colors: [
            Color(red: 26, green: 28, blue: 44),   // Dark blue
            Color(red: 93, green: 39, blue: 93),   // Purple
            Color(red: 177, green: 62, blue: 83),  // Pink
            Color(red: 238, green: 108, blue: 77), // Orange
            Color(red: 255, green: 205, blue: 117) // Yellow
        ])
        
        return processor.applyPalette(image, palette: customPalette)
    }
    
    func createGrayscalePixelArt(_ image: PlatformImage) -> PlatformImage? {
        // First pixelate, then convert to grayscale
        let config = PixelArtConfiguration(pixelSize: 10)
        guard let pixelated = processor.pixelate(image, using: config) else {
            return nil
        }
        return processor.convertToGrayscale(pixelated)
    }
    
    func completeProcessingPipeline(_ image: PlatformImage) -> PlatformImage? {
        let config = PixelArtConfiguration(
            pixelSize: 8,
            maxSize: CGSize(width: 400, height: 400),
            colorPalette: .retro
        )
        
        return processor.processPixelArt(image, configuration: config)
    }
    
    func stepByStepProcessing(_ image: PlatformImage) -> PlatformImage? {
        // Step 1: Pixelate
        let pixelated = processor.pixelate(image)
        
        // Step 2: Apply palette
        guard let withPalette = processor.applyPalette(pixelated ?? image, palette: .retro) else {
            return nil
        }
        
        return withPalette
    }
}