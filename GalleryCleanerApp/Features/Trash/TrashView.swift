import SwiftUI

public struct TrashView: View {
    @ObservedObject var trashManager: TrashManager = .shared
    @ObservedObject var photoService: PhotoLibraryService = .shared
    
    @State private var selectedFilter: DateFilterOption = .all
    @State private var showingEmptyConfirmation: Bool = false
    @State private var showingPermanentDeleteConfirmation: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    public init() {}
    
    private var filteredItems: [TrashedItem] {
        trashManager.items.filter { selectedFilter.matches(date: $0.trashedDate) }
    }
    
    private var allFilteredSelected: Bool {
        let visibleIds = filteredItems.map { $0.id }
        return !visibleIds.isEmpty && visibleIds.allSatisfy { trashManager.selectedItemIds.contains($0) }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if trashManager.items.isEmpty {
                    EmptyStateView(
                        icon: "trash.slash.fill",
                        title: "Trash is Empty",
                        message: "Photos and videos moved to trash will appear here before permanent deletion.",
                        iconTint: .red
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Subheader Row (Matches Screenshot 5)
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(filteredItems.count) Items in Trash")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    let reclaimBytes = filteredItems.reduce(0) { $0 + $1.mediaItem.fileSize }
                                    Text("\(ByteCountFormatter.string(fromByteCount: reclaimBytes, countStyle: .file)) reclaimable")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.orange)
                                }
                                
                                Spacer()
                                
                                Button(allFilteredSelected ? "Deselect All" : "Select All") {
                                    trashManager.selectAll(visibleIds: filteredItems.map { $0.id })
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Date Filter Pills (Matches Screenshot 5)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(DateFilterOption.allCases) { filter in
                                        let isSelected = (selectedFilter == filter)
                                        Button(action: {
                                            selectedFilter = filter
                                            HapticFeedback.selection()
                                        }) {
                                            Text(filter.rawValue)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(isSelected ? .white : .primary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(isSelected ? Color.red : Color(UIColor.systemGray5))
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Grid of Trashed Items (Matches Screenshot 5)
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(filteredItems) { item in
                                    let isSelected = trashManager.selectedItemIds.contains(item.id)
                                    MediaThumbnailView(
                                        item: item.mediaItem,
                                        isSelected: isSelected,
                                        showSelectionBadge: true,
                                        showSizeBadge: true,
                                        cornerRadius: 12
                                    )
                                    .frame(height: 120)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        trashManager.toggleSelection(for: item.id)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Trash (\(trashManager.items.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !trashManager.items.isEmpty {
                        Button("Empty All") {
                            showingEmptyConfirmation = true
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if !trashManager.selectedItemIds.isEmpty {
                    floatingActionBar
                }
            }
            .confirmationDialog(
                "Empty Trash?",
                isPresented: $showingEmptyConfirmation,
                titleVisibility: .visible
            ) {
                Button("Permanently Delete All Items", role: .destructive) {
                    Task {
                        await trashManager.emptyAll(photoService: photoService)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. Items will be permanently removed from your gallery.")
            }
            .confirmationDialog(
                "Delete Selected Items?",
                isPresented: $showingPermanentDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Permanently Delete (\(trashManager.selectedItemIds.count))", role: .destructive) {
                    Task {
                        await trashManager.deleteSelectedPermanently(photoService: photoService)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Selected items will be permanently removed from your device.")
            }
        }
    }
    
    // Bottom Dual Floating Action Buttons (Matches Screenshot 5)
    private var floatingActionBar: some View {
        HStack(spacing: 14) {
            // Restore Button (Blue)
            Button(action: {
                trashManager.restoreSelected()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .bold))
                    Text("Restore (\(trashManager.selectedItemIds.count))")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue)
                .clipShape(Capsule())
                .shadow(color: Color.blue.opacity(0.3), radius: 6, y: 3)
            }
            
            // Delete Permanently Button (Red)
            Button(action: {
                showingPermanentDeleteConfirmation = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Delete (\(trashManager.selectedItemIds.count))")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red)
                .clipShape(Capsule())
                .shadow(color: Color.red.opacity(0.3), radius: 6, y: 3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Color(UIColor.systemBackground).opacity(0), Color(UIColor.systemBackground).opacity(0.95), Color(UIColor.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
