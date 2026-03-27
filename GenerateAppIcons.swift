#!/usr/bin/env swift
// Run from project root: swift GenerateAppIcons.swift
import AppKit

let outputDir = "Stack/Assets.xcassets/AppIcon.appiconset"

// All unique pixel sizes needed for iOS + macOS icon sets
let sizes = [16, 20, 29, 32, 40, 58, 60, 64, 76, 80, 87, 120, 128, 152, 167, 180, 256, 512, 1024]

func drawIcon(size: Int) -> Data? {
    let dim = CGFloat(size)

    guard let cs = CGColorSpace(name: CGColorSpace.sRGB),
          let ctx = CGContext(
              data: nil,
              width: size, height: size,
              bitsPerComponent: 8,
              bytesPerRow: 0,
              space: cs,
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
          ) else { return nil }

    func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
        CGColor(colorSpace: cs, components: [r/255, g/255, b/255, a])!
    }

    // Background: #080810
    ctx.setFillColor(rgb(8, 8, 16))
    ctx.fill(CGRect(x: 0, y: 0, width: dim, height: dim))

    // Radial glow: indigo, centered
    let center = CGPoint(x: dim / 2, y: dim / 2)
    let glowColors = [rgb(99, 102, 241, 0.35), rgb(99, 102, 241, 0)] as CFArray
    let locs: [CGFloat] = [0, 1]
    if let grad = CGGradient(colorsSpace: cs, colors: glowColors, locations: locs) {
        ctx.drawRadialGradient(
            grad,
            startCenter: center, startRadius: 0,
            endCenter: center,   endRadius: dim * 0.38,
            options: []
        )
    }

    // Bars — top: indigo (shortest), mid: purple, bot: gold (longest)
    let barH   = dim * 0.09
    let corner = barH / 2
    let gap    = dim * 0.055
    let widths: [CGFloat]  = [dim * 0.48, dim * 0.63, dim * 0.78]
    let colors: [CGColor]  = [
        rgb(99,  102, 241),   // indigo — top
        rgb(139, 92,  246),   // purple — middle
        rgb(245, 158, 11),    // gold   — bottom
    ]

    let stackH = barH * 3 + gap * 2
    let startY = (dim - stackH) / 2  // CG y-up: startY is the bottom of the stack

    for i in 0..<3 {
        let w  = widths[i]
        let x  = (dim - w) / 2
        // i=0 (indigo) → visual top → highest y in CG coordinates
        let y  = startY + CGFloat(2 - i) * (barH + gap)
        let path = CGPath(roundedRect: CGRect(x: x, y: y, width: w, height: barH),
                          cornerWidth: corner, cornerHeight: corner, transform: nil)
        ctx.addPath(path)
        ctx.setFillColor(colors[i])
        ctx.fillPath()
    }

    guard let cgImage = ctx.makeImage() else { return nil }
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: dim, height: dim))
    guard let tiff = nsImage.tiffRepresentation,
          let rep  = NSBitmapImageRep(data: tiff),
          let png  = rep.representation(using: .png, properties: [:]) else { return nil }
    return png
}

// Ensure output directory exists
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

var generated = 0
for size in sizes {
    let path = "\(outputDir)/icon-\(size).png"
    if let data = drawIcon(size: size) {
        do {
            try data.write(to: URL(fileURLWithPath: path))
            print("✓ icon-\(size).png")
            generated += 1
        } catch {
            print("✗ icon-\(size).png: \(error)")
        }
    } else {
        print("✗ icon-\(size).png: render failed")
    }
}
print("\n\(generated)/\(sizes.count) icons generated → \(outputDir)")
