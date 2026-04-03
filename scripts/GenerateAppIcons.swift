import AppKit
import Foundation

struct Palette {
    let outerTop: NSColor
    let outerBottom: NSColor
    let tile: NSColor
    let line: NSColor
    let coin: NSColor
    let glyph: NSColor
    let shadow: NSColor
}

private let canvasSize: CGFloat = 1024

private func color(_ hex: UInt32, alpha: CGFloat = 1.0) -> NSColor {
    NSColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255.0,
        green: CGFloat((hex >> 8) & 0xFF) / 255.0,
        blue: CGFloat(hex & 0xFF) / 255.0,
        alpha: alpha
    )
}

private func drawLinearGradient(in rect: CGRect, top: NSColor, bottom: NSColor) {
    let gradient = NSGradient(starting: top, ending: bottom)
    gradient?.draw(in: rect, angle: -90)
}

private func roundedRect(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

private func drawIcon(palette: Palette, outputURL: URL) throws {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(canvasSize),
        pixelsHigh: Int(canvasSize),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: canvasSize, height: canvasSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let fullRect = CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize)
    drawLinearGradient(in: fullRect, top: palette.outerTop, bottom: palette.outerBottom)

    let tileRect = CGRect(x: 210, y: 220, width: 604, height: 604)
    let tileShadow = NSShadow()
    tileShadow.shadowColor = palette.shadow
    tileShadow.shadowBlurRadius = 38
    tileShadow.shadowOffset = NSSize(width: 0, height: -18)
    tileShadow.set()
    palette.tile.setFill()
    roundedRect(tileRect, radius: 132).fill()

    NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let lineRects = [
        CGRect(x: 328, y: 636, width: 286, height: 26),
        CGRect(x: 328, y: 514, width: 286, height: 26),
        CGRect(x: 328, y: 392, width: 286, height: 26),
    ]
    palette.line.setFill()
    for rect in lineRects {
        roundedRect(rect, radius: 13).fill()
    }

    let coinRect = CGRect(x: 580, y: 276, width: 182, height: 182)
    palette.coin.setFill()
    NSBezierPath(ovalIn: coinRect).fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    let font = NSFont(name: "Georgia", size: 124) ?? NSFont.systemFont(ofSize: 124, weight: .regular)
    let glyphAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: palette.glyph,
        .paragraphStyle: paragraph,
        .kern: -2.0
    ]
    let glyph = NSAttributedString(string: "P", attributes: glyphAttributes)
    let glyphRect = CGRect(x: coinRect.minX, y: coinRect.minY + 24, width: coinRect.width, height: 128)
    glyph.draw(in: glyphRect)

    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GenerateAppIcons", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PNG data"])
    }
    try pngData.write(to: outputURL)
}

let fileManager = FileManager.default
let appIconDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Pantri/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
try fileManager.createDirectory(at: appIconDirectory, withIntermediateDirectories: true)

let primary = Palette(
    outerTop: color(0xF8F1E5),
    outerBottom: color(0xE8DECF),
    tile: color(0x402F24),
    line: color(0xEFE1CF),
    coin: color(0xC9B292),
    glyph: color(0xFFF8F0),
    shadow: color(0x291D15, alpha: 0.22)
)

let dark = Palette(
    outerTop: color(0x35271E),
    outerBottom: color(0x211812),
    tile: color(0xF0E3D0),
    line: color(0x473428),
    coin: color(0x8D7258),
    glyph: color(0xFFF7EE),
    shadow: color(0x000000, alpha: 0.12)
)

let tinted = Palette(
    outerTop: color(0xF0ECE4),
    outerBottom: color(0xDDD6C8),
    tile: color(0x705742),
    line: color(0xF0E7DA),
    coin: color(0xCDB598),
    glyph: color(0xFFF8F1),
    shadow: color(0x564635, alpha: 0.10)
)

try drawIcon(palette: primary, outputURL: appIconDirectory.appendingPathComponent("AppIcon-Primary-1024.png"))
try drawIcon(palette: dark, outputURL: appIconDirectory.appendingPathComponent("AppIcon-Dark-1024.png"))
try drawIcon(palette: tinted, outputURL: appIconDirectory.appendingPathComponent("AppIcon-Tinted-1024.png"))
