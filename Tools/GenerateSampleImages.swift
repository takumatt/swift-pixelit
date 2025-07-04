#!/usr/bin/env swift

import Foundation
import CoreGraphics

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// Create a sample image with gradients and geometric shapes
func createSampleImage() -> CGImage? {
    let width = 400
    let height = 400
    
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
    
    // Background gradient
    let colors = [
        CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
        CGColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1.0),
        CGColor(red: 0.4, green: 0.8, blue: 0.2, alpha: 1.0)
    ]
    
    let locations: [CGFloat] = [0.0, 0.5, 1.0]
    
    guard let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: colors as CFArray,
        locations: locations
    ) else {
        return nil
    }
    
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: 0),
        end: CGPoint(x: width, y: height),
        options: []
    )
    
    // Add some geometric shapes
    // Circle
    context.setFillColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.8)
    context.fillEllipse(in: CGRect(x: 50, y: 50, width: 100, height: 100))
    
    // Rectangle
    context.setFillColor(red: 0.9, green: 0.1, blue: 0.7, alpha: 0.7)
    context.fill(CGRect(x: 250, y: 150, width: 80, height: 120))
    
    // Triangle (using path)
    context.setFillColor(red: 0.1, green: 0.9, blue: 0.8, alpha: 0.6)
    context.beginPath()
    context.move(to: CGPoint(x: 150, y: 250))
    context.addLine(to: CGPoint(x: 200, y: 350))
    context.addLine(to: CGPoint(x: 100, y: 350))
    context.closePath()
    context.fillPath()
    
    // Add some text-like patterns
    for i in 0..<10 {
        let x = 20 + i * 35
        let y = 300 + (i % 3) * 20
        context.setFillColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        context.fill(CGRect(x: x, y: y, width: 25, height: 15))
    }
    
    return context.makeImage()
}

// Save image as PNG
func saveImageAsPNG(_ image: CGImage, to path: String) -> Bool {
    let url = URL(fileURLWithPath: path)
    
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
        return false
    }
    
    CGImageDestinationAddImage(destination, image, nil)
    return CGImageDestinationFinalize(destination)
}

// Create and save the sample image
if let sampleImage = createSampleImage() {
    let imagePath = "/Users/tmatsushita/ghq/github.com/takumatt/swift-pixelit/docs/images/sample-original.png"
    if saveImageAsPNG(sampleImage, to: imagePath) {
        print("Sample image saved to: \(imagePath)")
    } else {
        print("Failed to save sample image")
    }
} else {
    print("Failed to create sample image")
}