import XCTest
@testable import SwiftPixelIt

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

final class SwiftPixelItTests: XCTestCase {
    
    func testPixelItInitialization() {
        let pixelIt = PixelIt()
        XCTAssertNotNil(pixelIt)
    }
    
    func testSetScale() {
        let pixelIt = PixelIt()
        let result = pixelIt.setScale(10)
        XCTAssertIdentical(result, pixelIt)
    }
    
    func testSetPalette() {
        let pixelIt = PixelIt()
        let palette = ColorPalette.defaultPalette
        let result = pixelIt.setPalette(palette)
        XCTAssertIdentical(result, pixelIt)
    }
    
    func testColorPaletteDefaultPalette() {
        let palette = ColorPalette.defaultPalette
        XCTAssertFalse(palette.colors.isEmpty)
        XCTAssertEqual(palette.colors.count, 9)
    }
    
    func testColorPaletteCustomPalette() {
        let customColors = [[255, 0, 0], [0, 255, 0], [0, 0, 255]]
        let palette = ColorPalette(colors: customColors)
        XCTAssertEqual(palette.colors.count, 3)
        XCTAssertEqual(palette.colors[0], [255, 0, 0])
    }
    
    func testPixelateWithoutImage() {
        let pixelIt = PixelIt()
        let result = pixelIt.pixelate()
        XCTAssertNil(result)
    }
    
    func testConvertPaletteWithoutImage() {
        let pixelIt = PixelIt()
        let result = pixelIt.convertPalette()
        XCTAssertNil(result)
    }
    
    func testConvertGrayscaleWithoutImage() {
        let pixelIt = PixelIt()
        let result = pixelIt.convertGrayscale()
        XCTAssertNil(result)
    }
    
    func testMethodChaining() {
        let pixelIt = PixelIt()
        let palette = ColorPalette.defaultPalette
        
        let result = pixelIt
            .setScale(5)
            .setPalette(palette)
            .setMaxWidth(100)
            .setMaxHeight(100)
        
        XCTAssertIdentical(result, pixelIt)
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
    
    func testPixelateWithImage() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let pixelIt = PixelIt(from: testImage)
        let result = pixelIt.setScale(10).pixelate()
        
        XCTAssertNotNil(result)
    }
    
    func testConvertGrayscaleWithImage() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let pixelIt = PixelIt(from: testImage)
        let result = pixelIt.convertGrayscale()
        
        XCTAssertNotNil(result)
    }
    
    func testConvertPaletteWithImage() {
        guard let testImage = createTestImage() else {
            XCTFail("Failed to create test image")
            return
        }
        
        let pixelIt = PixelIt(from: testImage)
        let result = pixelIt.setPalette(ColorPalette.defaultPalette).convertPalette()
        
        XCTAssertNotNil(result)
    }
}