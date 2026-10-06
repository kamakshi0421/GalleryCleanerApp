import Foundation
import SwiftUI
import Combine

public struct TrashedItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let mediaItem: MediaItem
    public let trashedDate: Date
    
    public init(mediaItem: MediaItem, trashedDate: Date = Date()) {
        self.id = mediaItem.id
        self.mediaItem = mediaItem
        self.trashedDate = trashedDate
    }
}

@MainActor
public final class TrashManager: ObservableObject {
    public static let shared = TrashManager()
    
    @Published public var items: [TrashedItem] = []
    @Published public var selectedItemIds: Set<String> = []
    
    private init() {
        self.items = []
        self.selectedItemIds = []
    }
    
    public var totalReclaimableSpace: Int64 {
        items.reduce(0) { $0 + $1.mediaItem.fileSize }
    }
    
    public var formattedTotalReclaimableSpace: String {
        ByteCountFormatter.string(fromByteCount: totalReclaimableSpace, countStyle: .file)
    }
    
    public var selectedReclaimableSpace: Int64 {
        items.filter { selectedItemIds.contains($0.id) }
            .reduce(0) { $0 + $1.mediaItem.fileSize }
    }
    
    public var formattedSelectedReclaimableSpace: String {
        ByteCountFormatter.string(fromByteCount: selectedReclaimableSpace, countStyle: .file)
    }
    
    public func moveToTrash(items newItems: [MediaItem]) {
        for mediaItem in newItems {
            if !items.contains(where: { $0.id == mediaItem.id }) {
                items.append(TrashedItem(mediaItem: mediaItem))
                selectedItemIds.insert(mediaItem.id)
            }
        }
    }
    
    public func toggleSelection(for id: String) {
        if selectedItemIds.contains(id) {
            selectedItemIds.remove(id)
        } else {
            selectedItemIds.insert(id)
        }
        HapticFeedback.selection()
    }
    
    public func selectAll(visibleIds: [String]) {
        if selectedItemIds.count == visibleIds.count {
            selectedItemIds.removeAll()
        } else {
            selectedItemIds = Set(visibleIds)
        }
        HapticFeedback.selection()
    }
    
    public func restoreSelected() {
        let toRestore = selectedItemIds
        items.removeAll { toRestore.contains($0.id) }
        selectedItemIds.removeAll()
        HapticFeedback.success()
    }
    
    public func deleteSelectedPermanently(photoService: PhotoLibraryService) async {
        let toDelete = Array(selectedItemIds)
        do {
            try await photoService.deleteAssets(identifiers: toDelete)
        } catch {
            // Log or fallback
        }
        items.removeAll { selectedItemIds.contains($0.id) }
        selectedItemIds.removeAll()
        HapticFeedback.heavy()
    }
    
    public func emptyAll(photoService: PhotoLibraryService) async {
        let allIds = items.map { $0.id }
        do {
            try await photoService.deleteAssets(identifiers: allIds)
        } catch {}
        items.removeAll()
        selectedItemIds.removeAll()
        HapticFeedback.heavy()
    }
}
