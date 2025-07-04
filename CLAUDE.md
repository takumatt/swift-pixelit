# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftPixelIt is a Swift library for converting images into pixel art, inspired by the JavaScript pixelit library. It provides high-performance image processing using Core Graphics and supports both iOS and macOS platforms.

## Architecture

The library is structured with a main `PixelIt` class and several extension files:

- `PixelIt.swift` - Core class with configuration methods and platform abstraction
- `PixelIt+Processing.swift` - Pixelation algorithms and image resizing
- `PixelIt+Palette.swift` - Color palette conversion and color matching algorithms
- `PixelIt+Grayscale.swift` - Grayscale conversion functionality

The library uses a fluent API pattern with method chaining for easy configuration.

## Key Design Patterns

1. **Platform Abstraction**: Uses `PlatformImage` typealias to support both UIKit (iOS) and AppKit (macOS)
2. **Fluent Interface**: All configuration methods return `self` for method chaining
3. **Internal Access**: Core properties and helper methods use `internal` access level for extension access
4. **Core Graphics**: All image processing uses Core Graphics for performance and consistency

## Common Development Tasks

### Build and Test
```bash
swift build
swift test
```

### Package Structure
- Sources/SwiftPixelIt/ - Main library code
- Tests/SwiftPixelItTests/ - Unit tests
- Examples/ - Usage examples

### Adding New Features

When adding new image processing methods:
1. Create a new extension file (e.g., `PixelIt+NewFeature.swift`)
2. Use `internal` access for helper methods that need to access class properties
3. Follow the existing pattern of checking for `sourceImage` and `cgImage`
4. Use Core Graphics contexts for image manipulation
5. Return `PlatformImage?` for consistency

### Testing

All public methods should have corresponding tests. Use the `createTestImage()` helper method in tests for generating test images programmatically.

## Platform Support

- iOS 13.0+
- macOS 10.15+
- Uses conditional compilation for platform-specific code (`#if canImport(UIKit)`)