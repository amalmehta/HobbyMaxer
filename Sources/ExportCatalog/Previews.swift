// Link-preview pages and images for chat apps (iMessage, Slack, WhatsApp…), which read
// Open Graph tags from static HTML and don't run JavaScript. Each hobby gets
// website/h/<slug>/index.html (tags + redirect to the app), website/previews/<slug>.jpg, and
// website/h/<slug>/<0-100>/index.html so a shared link's preview can carry the match %: exact in the
// title, and on the image as a "~80%" badge rounded to 5% (website/previews/<slug>-<25…100>.jpg)
// to keep the repo small. Below 25% the plain image is used.
import AppKit
import Foundation
import HobbyMaxerCore

enum Previews {
    static let size = NSSize(width: 1200, height: 630)
    static let coral = NSColor(red: 0.93, green: 0.42, blue: 0.30, alpha: 1)
    static let ink = NSColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
    static let muted = NSColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1)

    static let badgeSteps = Array(stride(from: 25, through: 100, by: 5))

    /// The badge an exact percentage shows, rounded to the nearest 5; nil below 25%.
    static func badge(for percent: Int) -> Int? {
        let rounded = Int((Double(percent) / 5).rounded()) * 5
        return rounded >= 25 ? min(rounded, 100) : nil
    }

    /// "a 79%" but "an 80%", "an 8%", "an 11%", "an 18%".
    static func article(_ percent: Int) -> String {
        [8, 11, 18].contains(percent) || (80...89).contains(percent) ? "an" : "a"
    }

    static func write(to folder: URL) throws {
        let images = folder.appendingPathComponent("previews")
        try? FileManager.default.removeItem(at: images)
        try? FileManager.default.removeItem(at: folder.appendingPathComponent("h"))
        try FileManager.default.createDirectory(at: images, withIntermediateDirectories: true)

        try image(emoji: "🎯", title: "Hobby Maxer",
                  subtitle: "Find hobbies that fit you — and a 3-step plan to start one.",
                  lines: ["11 quick questions", "\(Catalog.all.count) hobbies", "Free, nothing to sign up for"],
                  numbered: false)
            .write(to: images.appendingPathComponent("default.jpg"))

        for hobby in Catalog.all {
            let slug = ResultLink.slug(hobby.name)
            for badge in [nil] + badgeSteps.map(Optional.some) {
                try image(emoji: hobby.emoji, title: hobby.name, subtitle: hobby.tagline,
                          lines: hobby.steps.map(\.title), numbered: true, badge: badge)
                    .write(to: images.appendingPathComponent(badge.map { "\(slug)-\($0).jpg" } ?? "\(slug).jpg"))
            }
            for percent in [nil] + (0...100).map(Optional.some) {
                let path = percent.map { "h/\(slug)/\($0)/index.html" } ?? "h/\(slug)/index.html"
                let page = folder.appendingPathComponent(path)
                try FileManager.default.createDirectory(at: page.deletingLastPathComponent(), withIntermediateDirectories: true)
                try html(for: hobby, slug: slug, percent: percent).write(to: page, atomically: true, encoding: .utf8)
            }
        }
        print("Wrote \(Catalog.all.count * 102) preview pages and \(Catalog.all.count * (badgeSteps.count + 1) + 1) preview images")
    }

    // MARK: Page

    static func html(for hobby: Hobby, slug: String, percent: Int?) -> String {
        let site = ResultLink.website.absoluteString
        let here = "\(site)h/\(slug)/" + (percent.map { "\($0)/" } ?? "")
        let root = percent == nil ? "../../" : "../../../"
        let title = esc(percent.map { "\(hobby.name) — \(article($0)) \($0)% match for me" } ?? "\(hobby.name) — a Hobby Maxer match")
        let image = percent.flatMap(badge(for:)).map { "\(slug)-\($0).jpg" } ?? "\(slug).jpg"
        let alt = esc("\(hobby.emoji) \(hobby.name): \(hobby.tagline)"
            + (percent.flatMap(badge(for:)).map { " About \(article($0)) \($0)% match." } ?? ""))
        let description = esc(percent == nil
            ? "\(hobby.tagline) See the 3-step plan to get started."
            : "Hobby Maxer matched me with \(hobby.name). \(hobby.tagline) Here's the 3-step plan to start.")
        return """
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>\(esc(hobby.name)) · Hobby Maxer</title>
          <meta name="description" content="\(description)">
          <link rel="canonical" href="\(here)">
          <meta property="og:type" content="website">
          <meta property="og:site_name" content="Hobby Maxer">
          <meta property="og:title" content="\(title)">
          <meta property="og:description" content="\(description)">
          <meta property="og:url" content="\(here)">
          <meta property="og:image" content="\(site)previews/\(image)">
          <meta property="og:image:width" content="1200">
          <meta property="og:image:height" content="630">
          <meta property="og:image:alt" content="\(alt)">
          <meta name="twitter:card" content="summary_large_image">
          <!-- Generated by `swift run ExportCatalog website` — don't hand-edit. -->
          <script>
            const params = new URLSearchParams(location.search);
            params.set("h", "\(slug)");
            location.replace("\(root)?" + params.toString().replace(/%2C/g, ","));
          </script>
        </head>
        <body>
          <p><a href="\(root)">Open Hobby Maxer</a></p>
        </body>
        </html>

        """
    }

    static func esc(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
    }

    // MARK: Image

    static func image(emoji: String, title: String, subtitle: String, lines: [String], numbered: Bool,
                      badge: Int? = nil) -> Data {
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

        // Match badge on the tile's bottom-right corner
        if let badge {
            let disc = NSRect(x: tile.maxX - 128, y: tile.maxY - 112, width: 150, height: 150)
            NSColor(red: 0.984, green: 0.980, blue: 0.973, alpha: 1).setFill()
            NSBezierPath(ovalIn: disc.insetBy(dx: -9, dy: -9)).fill()
            ink.setFill()
            NSBezierPath(ovalIn: disc).fill()
            let number = NSAttributedString(string: "~\(badge)%", attributes: [
                .font: rounded(badge == 100 ? 40 : 46, .heavy), .foregroundColor: NSColor.white])
            let label = NSAttributedString(string: "MATCH", attributes: [
                .font: rounded(19, .heavy), .foregroundColor: NSColor(red: 1.0, green: 0.62, blue: 0.42, alpha: 1), .kern: 2])
            let n = number.size(), l = label.size()
            let top = disc.midY - (n.height + l.height - 6) / 2
            number.draw(at: NSPoint(x: disc.midX - n.width / 2, y: top))
            label.draw(at: NSPoint(x: disc.midX - l.width / 2 + 1, y: top + n.height - 6))
        }

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

    static func rounded(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
        let base = NSFont.systemFont(ofSize: size, weight: weight)
        return base.fontDescriptor.withDesign(.rounded).flatMap { NSFont(descriptor: $0, size: size) } ?? base
    }
}
