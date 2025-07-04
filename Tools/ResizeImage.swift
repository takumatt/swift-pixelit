#!/usr/bin/env swift

import Foundation
import CoreGraphics

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

func loadImage(from path: String) -> CGImage? {
    let url = URL(fileURLWithPath: path)
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        return nil
    }
    return image
}

func saveImage(_ image: CGImage, to path: String) -> Bool {
    let url = URL(fileURLWithPath: path)
    
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
        return false
    }
    
    CGImageDestinationAddImage(destination, image, nil)
    return CGImageDestinationFinalize(destination)
}

func resizeImage(_ image: CGImage, maxWidth: Int) -> CGImage? {
    let originalWidth = image.width
    let originalHeight = image.height
    
    // Calculate new dimensions maintaining aspect ratio
    let ratio = Double(maxWidth) / Double(originalWidth)
    let newWidth = maxWidth
    let newHeight = Int(Double(originalHeight) * ratio)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    guard let context = CGContext(
        data: nil,
        width: newWidth,
        height: newHeight,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
    ) else {
        return nil
    }
    
    context.interpolationQuality = .high
    context.draw(image, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    return context.makeImage()
}

// Resize the original image
let originalPath = "/Users/tmatsushita/ghq/github.com/takumatt/swift-pixelit/docs/images/alex-panarin-2-a-R0glb48-unsplash.jpg"
let resizedPath = "/Users/tmatsushita/ghq/github.com/takumatt/swift-pixelit/docs/images/example-original.png"

guard let originalImage = loadImage(from: originalPath) else {
    print("Failed to load original image")
    exit(1)
}

print("Original size: \(originalImage.width) x \(originalImage.height)")

guard let resizedImage = resizeImage(originalImage, maxWidth: 400) else {
    print("Failed to resize image")
    exit(1)
}

print("Resized size: \(resizedImage.width) x \(resizedImage.height)")

if saveImage(resizedImage, to: resizedPath) {
    print("Resized image saved to: \(resizedPath)")
} else {
    print("Failed to save resized image")
    exit(1)
}