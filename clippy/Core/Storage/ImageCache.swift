import AppKit
import ImageIO

// MARK: - In-Memory Image & Icon Cache with Image I/O Downsampling

/// High-performance memory cache and background downsampler for clipboard images and app icons.
/// Eliminates main-thread disk I/O and large image decoding during shelf spring animations.
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let imageCache = NSCache<NSString, NSImage>()
    private let iconCache = NSCache<NSString, NSImage>()

    private init() {
        // Cache up to 150 image thumbnails (~15MB RAM) and up to 50 app icons (~500KB RAM)
        imageCache.countLimit = 150
        imageCache.totalCostLimit = 80 * 1024 * 1024 // 80 MB
        iconCache.countLimit = 50
    }

    // MARK: - Synchronous In-Memory Lookups (0.001 ms)

    /// Retrieves an image from RAM cache if already loaded.
    func image(for key: String) -> NSImage? {
        imageCache.object(forKey: key as NSString)
    }

    /// Stores a decoded image in the RAM cache.
    func store(_ image: NSImage, for key: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        imageCache.setObject(image, forKey: key as NSString, cost: cost)
    }

    /// Retrieves or downsamples a cached app icon (36x36 for Retina 18x18 display).
    func icon(at path: String) -> NSImage? {
        if let cached = iconCache.object(forKey: path as NSString) {
            return cached
        }

        guard let original = NSImage(contentsOfFile: path) else { return nil }
        let size = NSSize(width: 36, height: 36)
        let resized = NSImage(size: size)
        resized.lockFocus()
        original.draw(
            in: NSRect(origin: .zero, size: size),
            from: NSRect(origin: .zero, size: original.size),
            operation: .copy,
            fraction: 1.0
        )
        resized.unlockFocus()
        iconCache.setObject(resized, forKey: path as NSString)
        return resized
    }

    // MARK: - Asynchronous Background Thumbnail Loading

    /// Loads, downsamples, and caches a thumbnail for `item` on a background thread.
    /// Never blocks the main thread.
    func loadThumbnail(for item: ClipboardItem, maxDimension: CGFloat = 350) async -> NSImage? {
        let key = item.id.uuidString
        if let cached = image(for: key) {
            return cached
        }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }

                // 1. Check if an existing thumbnail on disk is available
                if let thumbPath = item.thumbnailPath, FileManager.default.fileExists(atPath: thumbPath) {
                    if let img = NSImage(contentsOfFile: thumbPath) {
                        self.store(img, for: key)
                        continuation.resume(returning: img)
                        return
                    }
                }

                // 2. Downsample from storagePath directly using Image I/O
                guard let storagePath = item.storagePath, FileManager.default.fileExists(atPath: storagePath) else {
                    continuation.resume(returning: nil)
                    return
                }

                let storageURL = URL(fileURLWithPath: storagePath)
                if let (downsampledImage, jpegData) = self.downsample(at: storageURL, maxDimension: maxDimension) {
                    self.store(downsampledImage, for: key)

                    // Persist downsampled thumbnail to disk for instant loads next time
                    let thumbURL = LocalStorage.thumbnailsDirectoryURL.appendingPathComponent("\(key).jpg")
                    try? jpegData.write(to: thumbURL, options: .atomic)

                    continuation.resume(returning: downsampledImage)
                    return
                }

                // 3. Fallback to full file if downsampling failed
                if let fullImage = NSImage(contentsOfFile: storagePath) {
                    self.store(fullImage, for: key)
                    continuation.resume(returning: fullImage)
                    return
                }

                continuation.resume(returning: nil)
            }
        }
    }

    // MARK: - Background Pre-warming

    /// Pre-warms images and app icons in the background so they are ready in RAM before the user expands the shelf.
    func prewarm(items: [ClipboardItem], onThumbnailCreated: ((UUID, String) -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }
            for item in items {
                // Prewarm app icon
                if let iconPath = item.sourceApp?.cachedIconPath {
                    _ = self.icon(at: iconPath)
                }

                guard item.type == .image else { continue }
                let key = item.id.uuidString

                // Already in RAM
                if self.image(for: key) != nil { continue }

                // Check thumbnail on disk
                if let thumbPath = item.thumbnailPath, FileManager.default.fileExists(atPath: thumbPath) {
                    if let img = NSImage(contentsOfFile: thumbPath) {
                        self.store(img, for: key)
                        continue
                    }
                }

                // Generate thumbnail from storagePath
                if let storagePath = item.storagePath, FileManager.default.fileExists(atPath: storagePath) {
                    let storageURL = URL(fileURLWithPath: storagePath)
                    if let (downsampledImage, jpegData) = self.downsample(at: storageURL, maxDimension: 350) {
                        self.store(downsampledImage, for: key)
                        let thumbURL = LocalStorage.thumbnailsDirectoryURL.appendingPathComponent("\(key).jpg")
                        try? jpegData.write(to: thumbURL, options: .atomic)
                        onThumbnailCreated?(item.id, thumbURL.path)
                    }
                }
            }
        }
    }

    // MARK: - Image I/O Downsampling

    /// Creates a downsampled `NSImage` and JPEG representation from a file URL without loading the full bitmap into memory.
    func downsample(at url: URL, maxDimension: CGFloat) -> (NSImage, Data)? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }
        return processDownsample(source: source, maxDimension: maxDimension)
    }

    /// Creates a downsampled `NSImage` and JPEG representation from raw image data.
    func downsample(data: Data, maxDimension: CGFloat) -> (NSImage, Data)? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }
        return processDownsample(source: source, maxDimension: maxDimension)
    }

    private func processDownsample(source: CGImageSource, maxDimension: CGFloat) -> (NSImage, Data)? {
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        guard let jpegData = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.82]) else { return nil }
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        return (nsImage, jpegData)
    }
}
