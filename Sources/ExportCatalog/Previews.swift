// Link-preview images that need a Mac to draw (AppKit, Apple emoji, SF fonts):
//   website/previews/<slug>.jpg + default.jpg   one 1200×630 card per hobby, plus the site's card
//   website/previews/badges/<0-100>.png         exact "79% MATCH" badges (for the og/ preview server)
//   website/previews/badges/approx-<25…100>.png "~80% MATCH" badges, laid over the cards at deploy
// The 6,528 preview pages and the badged cards are built from these by scripts/previews/build.mjs
// during each GitHub deploy, so they aren't committed.
import AppKit
import Foundation
import HobbyMaxerCore

enum Previews {
    static let size = NSSize(width: 1200, height: 630)
    static let coral = NSColor(red: 0.93, green: 0.42, blue: 0.30, alpha: 1)
    static let ink = NSColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
    static let muted = NSColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1)

    static func write(to folder: URL) throws {
        let images = folder.appendingPathComponent("previews")
        try? FileManager.default.removeItem(at: images)
        let badges = images.appendingPathComponent("badges")
        try FileManager.default.createDirectory(at: badges, withIntermediateDirectories: true)

        for percent in 0...100 {
            try badgeImage("\(percent)%").write(to: badges.appendingPathComponent("\(percent).png"))
        }
        for step in stride(from: 25, through: 100, by: 5) {
            try badgeImage("~\(step)%").write(to: badges.appendingPathComponent("approx-\(step).png"))
        }

        // The preview server only draws images for hobbies it knows.
        let og = folder.deletingLastPathComponent().appendingPathComponent("og")
        if FileManager.default.fileExists(atPath: og.path) {
            let slugs = try JSONSerialization.data(withJSONObject: Catalog.all.map { ResultLink.slug($0.name) }, options: [.prettyPrinted])
            try slugs.write(to: og.appendingPathComponent("slugs.json"))
        }

        try image(emoji: "🎯", title: "Hobby Maxer",
                  subtitle: "Find hobbies that fit you — and a 3-step plan to start one.",
                  lines: ["11 quick questions", "\(Catalog.all.count) hobbies", "Free, nothing to sign up for"],
                  numbered: false)
            .write(to: images.appendingPathComponent("default.jpg"))
        for hobby in Catalog.all {
            try image(emoji: hobby.emoji, title: hobby.name, subtitle: hobby.tagline,
                      lines: hobby.steps.map(\.title), numbered: true)
                .write(to: images.appendingPathComponent("\(ResultLink.slug(hobby.name)).jpg"))
        }
        print("Wrote \(Catalog.all.count + 1) preview cards and 117 badges")
    }

    // MARK: Image

    static func image(emoji: String, title: String, subtitle: String, lines: [String], numbered: Bool) -> Data {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
                                   bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                   colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        let cg = NSGraphicsContext(bitmapImageRep: rep)!.cgContext
        cg.translateBy(x: 0, y: size.height)
        cg.scaleBy(x: 1, y: -1)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: true)

        NSColor(red: 0.984, green: 0.980, blue: 0.973, alpha: 1).setFill()
        NSRect(origin: .zero, size: size).fill()
        coral.setFill()
        NSRect(x: 0, y: 0, width: size.width, height: 14).fill()

        // Emoji tile
        let tile = NSRect(x: 72, y: 165, width: 300, height: 300)
        let path = NSBezierPath(roundedRect: tile, xRadius: 64, yRadius: 64)
        NSGradient(starting: NSColor(red: 1.0, green: 0.62, blue: 0.42, alpha: 1),
                   ending: NSColor(red: 0.88, green: 0.33, blue: 0.27, alpha: 1))!.draw(in: path, angle: 90)
        let glyph = NSAttributedString(string: emoji, attributes: [.font: NSFont.systemFont(ofSize: 170)])
        let g = glyph.size()
        glyph.draw(at: NSPoint(x: tile.midX - g.width / 2, y: tile.midY - g.height / 2))

        // Text column, measured first so it can be centered vertically.
        let x: CGFloat = 430, width = size.width - x - 64
        func column(from top: CGFloat, draw: Bool) -> CGFloat {
            var y = top
            func text(_ string: String, _ font: NSFont, _ color: NSColor, spacing: CGFloat, maxLines: Int = 1) {
                let attributed = NSAttributedString(string: string, attributes: [.font: font, .foregroundColor: color])
                let maxHeight = ceil(font.boundingRectForFont.height * CGFloat(maxLines))
                let height = min(ceil(attributed.boundingRect(with: NSSize(width: width, height: 1000),
                                                              options: .usesLineFragmentOrigin).height), maxHeight)
                if draw {
                    attributed.draw(with: NSRect(x: x, y: y, width: width, height: height),
                                    options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine])
                }
                y += height + spacing
            }
            text("HOBBY MAXER", rounded(28, .heavy), coral, spacing: 10)
            text(title, rounded(title.count > 18 ? 64 : 78, .bold), ink, spacing: 10, maxLines: 2)
            text(subtitle, .systemFont(ofSize: 33), muted, spacing: 30, maxLines: 2)
            if numbered { text("YOUR 3-STEP PLAN", rounded(22, .heavy), coral, spacing: 8) }
            for (i, line) in lines.enumerated() {
                text(numbered ? "\(i + 1)   \(line)" : "•   \(line)", .systemFont(ofSize: 31, weight: .medium), ink,
                     spacing: i == lines.count - 1 ? 0 : 8)
            }
            return y - top
        }
        let height = column(from: 0, draw: false)
        _ = column(from: max(40, (size.height - height) / 2 + 7), draw: true)

        NSGraphicsContext.restoreGraphicsState()
        return rep.representation(using: .jpeg, properties: [.compressionFactor: 0.8])!
    }

    /// Badges are 168×168 with a 9 px ring. They're laid over a card's emoji tile at (235, 344) —
    /// by scripts/previews/build.mjs and og/api/og.js.
    static let badgeSize = 168

    static func drawBadge(_ text: String, in disc: NSRect) {
        NSColor(red: 0.984, green: 0.980, blue: 0.973, alpha: 1).setFill()
        NSBezierPath(ovalIn: disc.insetBy(dx: -9, dy: -9)).fill()
        ink.setFill()
        NSBezierPath(ovalIn: disc).fill()
        let number = NSAttributedString(string: text, attributes: [
            .font: rounded(text.count >= 5 ? 40 : 46, .heavy), .foregroundColor: NSColor.white])
        let label = NSAttributedString(string: "MATCH", attributes: [
            .font: rounded(19, .heavy), .foregroundColor: NSColor(red: 1.0, green: 0.62, blue: 0.42, alpha: 1), .kern: 2])
        let n = number.size(), l = label.size()
        let top = disc.midY - (n.height + l.height - 6) / 2
        number.draw(at: NSPoint(x: disc.midX - n.width / 2, y: top))
        label.draw(at: NSPoint(x: disc.midX - l.width / 2 + 1, y: top + n.height - 6))
    }

    /// A transparent badge on its own, for the preview server to lay over a hobby card.
    static func badgeImage(_ text: String) -> Data {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: badgeSize, pixelsHigh: badgeSize,
                                   bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                   colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        let cg = NSGraphicsContext(bitmapImageRep: rep)!.cgContext
        cg.translateBy(x: 0, y: CGFloat(badgeSize))
        cg.scaleBy(x: 1, y: -1)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: true)
        drawBadge(text, in: NSRect(x: 9, y: 9, width: 150, height: 150))
        NSGraphicsContext.restoreGraphicsState()
        return rep.representation(using: .png, properties: [:])!
    }

    static func rounded(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
        let base = NSFont.systemFont(ofSize: size, weight: weight)
        return base.fontDescriptor.withDesign(.rounded).flatMap { NSFont(descriptor: $0, size: size) } ?? base
    }
}
