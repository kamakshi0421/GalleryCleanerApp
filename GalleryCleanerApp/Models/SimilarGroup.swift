import Foundation

public struct SimilarGroup: Identifiable, Sendable {
    public let id: String
    public let similarityScore: Double // 0.0 - 1.0 (e.g. 0.92)
    public var items: [MediaItem]
    public var selectedKeepId: String?
    
    public init(
        id: String = UUID().uuidString,
        similarityScore: Double = 0.9,
        items: [MediaItem],
        selectedKeepId: String? = nil
    ) {
        self.id = id
        self.similarityScore = similarityScore
        self.items = items
        self.selectedKeepId = selectedKeepId ?? items.first?.id
    }
    
    public var bestItem: MediaItem? {
        items.first { $0.id == selectedKeepId } ?? items.first
    }
    
    public var removableItems: [MediaItem] {
        guard let keepId = selectedKeepId else { return Array(items.dropFirst()) }
        return items.filter { $0.id != keepId }
    }
    
    public var reclaimableSpace: Int64 {
        removableItems.reduce(0) { $0 + $1.fileSize }
    }
    
    public var formattedReclaimableSpace: String {
        ByteCountFormatter.string(fromByteCount: reclaimableSpace, countStyle: .file)
    }
    
    public var formattedScore: String {
        let percent = Int(similarityScore * 100)
        return "\(percent)% match"
    }
}
