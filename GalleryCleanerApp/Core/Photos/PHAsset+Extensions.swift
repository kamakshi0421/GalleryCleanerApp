import Photos
#if canImport(UIKit)
import UIKit
#endif

extension PHAsset {
    /// Returns the estimated or actual file size in bytes using PHAssetResource
    public var resourceFileSize: Int64 {
        let resources = PHAssetResource.assetResources(for: self)
        var totalSize: Int64 = 0
        
        for resource in resources {
            if let fileSize = resource.value(forKey: "fileSize") as? Int64, fileSize > 0 {
                totalSize += fileSize
            }
        }
        
        // Fallback estimate based on dimensions if resource query returns 0
        if totalSize == 0 {
            if mediaType == .video {
                // Estimate ~2MB per second for standard 1080p video
                totalSize = Int64(max(1.0, duration) * 2_000_000)
            } else {
                // Estimate ~3MB for photos
                totalSize = Int64(pixelWidth * pixelHeight * 3) / 8
                if totalSize <= 0 { totalSize = 2_500_000 }
            }
        }
        
        return totalSize
    }
    
    public var isScreenshotAsset: Bool {
        return mediaSubtypes.contains(.photoScreenshot)
    }
}
