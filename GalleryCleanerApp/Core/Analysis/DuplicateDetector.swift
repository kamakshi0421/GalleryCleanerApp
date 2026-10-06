import Foundation

public final class DuplicateDetector: Sendable {
    public static let shared = DuplicateDetector()
    
    private init() {}
    
    /// Finds exact duplicate photos
    public func findDuplicatePhotos(from items: [MediaItem]) async -> [DuplicateGroup] {
        return await Task.detached(priority: .userInitiated) {
            // Group by signature: dimensions + fileSize (or mockTitle if mock)
            var groupsDictionary: [String: [MediaItem]] = [:]
            
            for item in items where item.isPhoto || item.isScreenshot {
                let signature: String
                if let mockTitle = item.mockTitle, !mockTitle.isEmpty {
                    signature = "\(item.pixelWidth)_\(item.pixelHeight)_\(item.fileSize)_\(mockTitle)"
                } else {
                    signature = "\(item.pixelWidth)_\(item.pixelHeight)_\(item.fileSize)"
                }
                groupsDictionary[signature, default: []].append(item)
            }
            
            var result: [DuplicateGroup] = []
            for (fingerprint, groupItems) in groupsDictionary where groupItems.count > 1 {
                let sortedItems = groupItems.sorted { $0.creationDate < $1.creationDate }
                result.append(DuplicateGroup(
                    fingerprint: fingerprint,
                    items: sortedItems
                ))
            }
            
            // Sort groups by reclaimable space descending (biggest savings first)
            return result.sorted { $0.reclaimableSpace > $1.reclaimableSpace }
        }.value
    }
    
    /// Finds exact duplicate videos
    public func findDuplicateVideos(from items: [MediaItem]) async -> [DuplicateGroup] {
        return await Task.detached(priority: .userInitiated) {
            var groupsDictionary: [String: [MediaItem]] = [:]
            
            for item in items where item.isVideo {
                let durationKey = Int(round(item.duration * 10)) // rounded to 0.1s
                let signature = "\(item.pixelWidth)_\(item.pixelHeight)_\(durationKey)_\(item.fileSize)"
                groupsDictionary[signature, default: []].append(item)
            }
            
            var result: [DuplicateGroup] = []
            for (fingerprint, groupItems) in groupsDictionary where groupItems.count > 1 {
                let sortedItems = groupItems.sorted { $0.creationDate < $1.creationDate }
                result.append(DuplicateGroup(
                    fingerprint: fingerprint,
                    items: sortedItems
                ))
            }
            
            return result.sorted { $0.reclaimableSpace > $1.reclaimableSpace }
        }.value
    }
}
