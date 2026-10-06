import Foundation

public struct DuplicateGroup: Identifiable, Sendable {
    public let id: String
    public let fingerprint: String
    public var items: [MediaItem]
    
    public init(id: String = UUID().uuidString, fingerprint: String, items: [MediaItem]) {
        self.id = id
        self.fingerprint = fingerprint
        self.items = items
    }
    
    /// The primary item recommended to keep (usually the earliest or highest resolution)
    public var primaryItem: MediaItem? {
        items.first
    }
    
    /// The duplicate items that can be safely removed
    public var duplicateItems: [MediaItem] {
        guard items.count > 1 else { return [] }
        return Array(items.dropFirst())
    }
    
    /// Total reclaimable size if duplicates are deleted
    public var reclaimableSpace: Int64 {
        duplicateItems.reduce(0) { $0 + $1.fileSize }
    }
    
    public var formattedReclaimableSpace: String {
        ByteCountFormatter.string(fromByteCount: reclaimableSpace, countStyle: .file)
    }
    
    public var totalSize: Int64 {
        items.reduce(0) { $0 + $1.fileSize }
    }
    
    public var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}
