#!/usr/bin/env swift

import Foundation
import CoreGraphics

#if canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#endif

// Simple version of the PixelIt functionality for sample generation
struct SampleProcessor {
    static func loadImage(from path: String) -> CGImage? {
        let url = URL(fileURLWithPath: path)
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }
        return image
    }
    
    static func saveImage(_ image: CGImage, to path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
            return false
        }
        
        CGImageDestinationAddImage(destination, image, nil)
        return CGImageDestinationFinalize(destination)
    }
    
    static func pixelate(_ image: CGImage, scale: Int) -> CGImage? {
        let width = image.width
        let height = image.height
        
        let pixelWidth = width / scale
        let pixelHeight = height / scale
        
        guard pixelWidth > 0, pixelHeight > 0 else { return nil }
        
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
        ) else { return nil }
        
        pixelContext.interpolationQuality = .none
        pixelContext.draw(image, in: CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight))
        
        guard let pixelatedSmall = pixelContext.makeImage() else { return nil }
        
        // Scale back up
        guard let finalContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        
        finalContext.interpolationQuality = .none
        finalContext.draw(pixelatedSmall, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return finalContext.makeImage()
    }
    
    static func convertToPalette(_ image: CGImage) -> CGImage? {
        let palette = [
            [26, 28, 44],
            [93, 39, 93],
            [177, 62, 83],
            [238, 108, 77],
            [255, 205, 117],
            [167, 219, 216],
            [68, 137, 26],
            [45, 45, 45],
            [255, 255, 255]
        ]
        
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
        ) else { return nil }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return nil }
        
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
                
                pixelData[pixelIndex] = UInt8(closestColor.0)
                pixelData[pixelIndex + 1] = UInt8(closestColor.1)
                pixelData[pixelIndex + 2] = UInt8(closestColor.2)
                pixelData[pixelIndex + 3] = a
            }
        }
        
        return context.makeImage()
    }
    
    static func findClosestColor(r: Int, g: Int, b: Int, in palette: [[Int]]) -> (Int, Int, Int) {
        var closestDistance = Double.infinity
        var closestColor = (0, 0, 0)
        
        for color in palette {
            let distance = sqrt(pow(Double(r - color[0]), 2) + pow(Double(g - color[1]), 2) + pow(Double(b - color[2]), 2))
            if distance < closestDistance {
                closestDistance = distance
                closestColor = (color[0], color[1], color[2])
            }
        }
        
        return closestColor
    }
}

// Process images
let originalPath = "/Users/tmatsushita/ghq/github.com/takumatt/swift-pixelit/docs/images/example-original.png"

guard let originalImage = SampleProcessor.loadImage(from: originalPath) else {
    print("Failed to load original image")
    exit(1)
}

// Create pixelated version
if let pixelatedImage = SampleProcessor.pixelate(originalImage, scale: 6) {
    let pixelatedPath = "/Users/tmatsushita/ghq/github.com/takumatt/swift-pixelit/docs/images/example-pixelated.png"
    if SampleProcessor.saveImage(pixelatedImage, to: pixelatedPath) {
        print("Pixelated image saved to: \(pixelatedPath)")
    }
    
    // Create palette version from pixelated
    if let paletteImage = SampleProcessor.convertToPalette(pixelatedImage) {
        let palettePath = "/Users/tmatsushita/ghq/github.com/takumatt/swift-pixelit/docs/images/example-palette.png"
        if SampleProcessor.saveImage(paletteImage, to: palettePath) {
            print("Palette image saved to: \(palettePath)")
        }
    }
}

print("Sample images generated successfully!")