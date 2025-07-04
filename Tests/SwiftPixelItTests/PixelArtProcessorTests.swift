import XCTest
@testable import SwiftPixelIt

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

final class PixelArtProcessorTests: XCTestCase {
    
    var processor: PixelArtProcessor!
    
    override func setUp() {
        super.setUp()
        processor = PixelArtProcessor()
    }
    
    override func tearDown() {
        processor = nil
        super.tearDown()
    }
    
    func testProcessorInitialization() {
        XCTAssertNotNil(processor)
    }
    
    func testPixelArtConfigurationDefaults() {
        let config = PixelArtConfiguration()
        XCTAssertEqual(config.pixelSize, 8)
        XCTAssertNil(config.maxSize)
        XCTAssertNil(config.colorPalette)
    }
    
    func testPixelArtConfigurationCustom() {
        let maxSize = CGSize(width: 200, height: 200)
        let palette = ColorPalette.retro
        let config = PixelArtConfiguration(
            pixelSize: 12,
            maxSize: maxSize,
            colorPalette: palette
        )
        
        XCTAssertEqual(config.pixelSize, 12)
        XCTAssertEqual(config.maxSize, maxSize)
        XCTAssertNotNil(config.colorPalette)
    }
    
    func testPixelSizeClampingInConfiguration() {
        let configLow = PixelArtConfiguration(pixelSize: -5)
        let configHigh = PixelArtConfiguration(pixelSize: 100)
        
        XCTAssertEqual(configLow.pixelSize, 1)
        XCTAssertEqual(configHigh.pixelSize, 50)
    }
    
    func testColorPaletteCreation() {
        let colors = [
            Color(red: 255, green: 0, blue: 0),
            Color(red: 0, green: 255, blue: 0),
            Color(red: 0, green: 0, blue: 255)
        ]
        let palette = ColorPalette(colors: colors)
        
        XCTAssertEqual(palette.colors.count, 3)
        XCTAssertEqual(palette.colors[0].red, 255)
        XCTAssertEqual(palette.colors[0].green, 0)
        XCTAssertEqual(palette.colors[0].blue, 0)
    }
    
    func testColorPaletteFromRGB() {
        let rgbColors = [[255, 0, 0], [0, 255, 0], [0, 0, 255]]
        let palette = ColorPalette(rgbColors: rgbColors)
        
        XCTAssertEqual(palette.colors.count, 3)
        XCTAssertEqual(palette.colors[0].red, 255)
        XCTAssertEqual(palette.colors[1].green, 255)
        XCTAssertEqual(palette.colors[2].blue, 255)
    }
    
    func testColorClampingInColor() {
        let color = Color(red: -10, green: 300, blue: 128)
        
        XCTAssertEqual(color.red, 0)
        XCTAssertEqual(color.green, 255)
        XCTAssertEqual(color.blue, 128)
    }
    
    func testRetroColorPalette() {
        let palette = ColorPalette.retro
        XCTAssertEqual(palette.colors.count, 9)
        XCTAssertEqual(palette.colors[0].red, 26)
        XCTAssertEqual(palette.colors[0].green, 28)
        XCTAssertEqual(palette.colors[0].blue, 44)
    }
    
    func testGameboyColorPalette() {
        let palette = ColorPalette.gameboy
        XCTAssertEqual(palette.colors.count, 4)
        XCTAssertEqual(palette.colors[0].red, 15)
        XCTAssertEqual(palette.colors[0].green, 56)
        XCTAssertEqual(palette.colors[0].blue, 15)
    }
    
    func testPixelateWithoutImage() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let result = processor.pixelate(testImage)
        XCTAssertNotNil(result)
    }
    
    func testPixelateWithConfiguration() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let config = PixelArtConfiguration(pixelSize: 16)
        let result = processor.pixelate(testImage, using: config)
        XCTAssertNotNil(result)
    }
    
    func testApplyPalette() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let result = processor.applyPalette(testImage, palette: .retro)
        XCTAssertNotNil(result)
    }
    
    func testConvertToGrayscale() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let result = processor.convertToGrayscale(testImage)
        XCTAssertNotNil(result)
    }
    
    func testProcessPixelArt() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let config = PixelArtConfiguration(
            pixelSize: 10,
            maxSize: CGSize(width: 100, height: 100),
            colorPalette: .retro
        )
        
        let result = processor.processPixelArt(testImage, configuration: config)
        XCTAssertNotNil(result)
    }
    
    func testProcessPixelArtWithoutPalette() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let config = PixelArtConfiguration(pixelSize: 8)
        let result = processor.processPixelArt(testImage, configuration: config)
        XCTAssertNotNil(result)
    }
    
    private func createTestImage() -> PlatformImage? {
        let size = CGSize(width: 100, height: 100)
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
        ) else {
            return nil
        }
        
        context.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        #if canImport(UIKit)
        return UIImage(cgImage: cgImage)
        #elseif canImport(AppKit)
        return NSImage(cgImage: cgImage, size: size)
        #endif
    }
}