# SwiftPixelIt

A Swift library for converting images into pixel art, inspired by the JavaScript pixelit library. Built with Core Graphics for high performance on iOS and macOS.

## Features

- Convert images to pixel art with configurable pixelation levels
- Apply custom color palettes to images
- Convert images to grayscale
- Support for both iOS and macOS
- Fluent API design with method chaining
- High performance using Core Graphics

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/takumatt/swift-pixelit.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/takumatt/swift-pixelit.git`

## Usage

### Basic Pixelation

```swift
import SwiftPixelIt

let pixelIt = PixelIt(from: yourImage)
let pixelatedImage = pixelIt
    .setScale(8)
    .pixelate()
```

### Custom Color Palette

```swift
let customPalette = ColorPalette(colors: [
    [26, 28, 44],
    [93, 39, 93],
    [177, 62, 83],
    [238, 108, 77],
    [255, 205, 117]
])

let pixelIt = PixelIt(from: yourImage)
let paletteImage = pixelIt
    .setPalette(customPalette)
    .convertPalette()
```

### Grayscale Conversion

```swift
let pixelIt = PixelIt(from: yourImage)
let grayscaleImage = pixelIt.convertGrayscale()
```

### Combined Processing

```swift
let pixelIt = PixelIt(from: yourImage)
let processedImage = pixelIt
    .setScale(6)
    .setMaxWidth(200)
    .setMaxHeight(200)
    .setPalette(ColorPalette.defaultPalette)
    .pixelate()
    .convertPalette()
```

## API Reference

### PixelIt Class

#### Initialization
- `init(from image: PlatformImage? = nil, palette: ColorPalette? = nil)`

#### Configuration Methods
- `setScale(_ scale: Int) -> PixelIt` - Set pixelation scale (1-50)
- `setPalette(_ palette: ColorPalette) -> PixelIt` - Set color palette
- `setMaxWidth(_ width: Int) -> PixelIt` - Set maximum width
- `setMaxHeight(_ height: Int) -> PixelIt` - Set maximum height
- `setSource(_ image: PlatformImage) -> PixelIt` - Set source image

#### Processing Methods
- `pixelate() -> PlatformImage?` - Apply pixelation effect
- `convertPalette() -> PlatformImage?` - Apply color palette conversion
- `convertGrayscale() -> PlatformImage?` - Convert to grayscale

### ColorPalette

```swift
let palette = ColorPalette(colors: [
    [255, 0, 0],   // Red
    [0, 255, 0],   // Green
    [0, 0, 255]    // Blue
])

// Use the default palette
let defaultPalette = ColorPalette.defaultPalette
```

## Platform Support

- iOS 13.0+
- macOS 10.15+

## License

MIT License - see LICENSE file for details.