import SwiftUI

public struct TrashView: View {
    @ObservedObject var trashManager: TrashManager = .shared
    @ObservedObject var photoService: PhotoLibraryService = .shared
    
    @State private var selectedFilter: DateFilterOption = .all
    @State private var showingEmptyConfirmation = false
    @State private var showingPermanentDeleteConfirmation = false
    @State private var isSelectionMode = false
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if trashManager.items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "trash",
                        description: Text("Items you delete will appear here.")
                    )
                } else {
                    // Native Segmented Control for filters
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(DateFilterOption.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(filteredItems) { item in
                                let isSelected = trashManager.selectedItemIds.contains(item.id)
                                MediaThumbnailView(
                                    item: item.mediaItem,
                                    isSelected: isSelected,
                                    showSelectionBadge: isSelectionMode,
                                    showSizeBadge: false,
                                    cornerRadius: 0 // Native photo grid uses sharp corners
                                )
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if isSelectionMode {
                                        trashManager.toggleSelection(for: item.id)
                                    } else {
                                        // Preview or toggle selection anyway
                                        trashManager.toggleSelection(for: item.id)
                                        isSelectionMode = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                        
                        let totalReclaimableBytes = filteredItems.reduce(0) { $0 + $1.mediaItem.fileSize }
                        Text("\(filteredItems.count) Items • \(ByteCountFormatter.string(fromByteCount: totalReclaimableBytes, countStyle: .file))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 24)
                            .padding(.bottom, 120) // Clear tab bar safely
                    }
                }
            }
            .navigationTitle("Recently Deleted")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !trashManager.items.isEmpty {
                        Button(isSelectionMode ? "Cancel" : "Select") {
                            withAnimation {
                                isSelectionMode.toggle()
                                if !isSelectionMode {
                                    trashManager.selectedItemIds.removeAll()
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelectionMode, !filteredItems.isEmpty {
                        let allSelected = trashManager.selectedItemIds.count == filteredItems.count
                        Button(allSelected ? "Deselect All" : "Select All") {
                            if allSelected {
                                trashManager.selectedItemIds.removeAll()
                            } else {
                                trashManager.selectAll(visibleIds: filteredItems.map { $0.id })
                            }
                        }
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    if !trashManager.items.isEmpty {
                        Button(isSelectionMode ? "Cancel" : "Select") {
                            withAnimation {
                                isSelectionMode.toggle()
                                if !isSelectionMode {
                                    trashManager.selectedItemIds.removeAll()
                                }
                            }
                        }
                    }
                }
                #endif
            }
            .safeAreaInset(edge: .bottom) {
                if !trashManager.items.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            if isSelectionMode {
                                Button("Recover") {
                                    trashManager.restoreSelected()
                                    isSelectionMode = false
                                }
                                .disabled(trashManager.selectedItemIds.isEmpty)
                                
                                Spacer()
                                
                                Button("Delete") {
                                    showingPermanentDeleteConfirmation = true
                                }
                                .disabled(trashManager.selectedItemIds.isEmpty)
                                .foregroundColor(trashManager.selectedItemIds.isEmpty ? .secondary : .red)
                            } else {
                                Spacer()
                                Button("Recover All") {
                                    trashManager.selectAll(visibleIds: trashManager.items.map { $0.id })
                                    trashManager.restoreSelected()
                                }
                                
                                Spacer()
                                
                                Button("Empty") {
                                    showingEmptyConfirmation = true
                                }
                                .foregroundColor(.red)
                                Spacer()
                            }
                        }
                        .padding()
                        .background(.bar)
                    }
                }
            }
            .confirmationDialog(
                "Empty Trash?",
                isPresented: $showingEmptyConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Items", role: .destructive) {
                    Task {
                        await trashManager.emptyAll(photoService: photoService)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
            .confirmationDialog(
                "Delete Selected Items?",
                isPresented: $showingPermanentDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete \(trashManager.selectedItemIds.count) Items", role: .destructive) {
                    Task {
                        await trashManager.deleteSelectedPermanently(photoService: photoService)
                        isSelectionMode = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("These items will be permanently removed.")
            }
        }
    }
    
    private var filteredItems: [TrashedItem] {
        let now = Date()
        return trashManager.items.filter { item in
            switch selectedFilter {
            case .all: return true
            case .today: return Calendar.current.isDateInToday(item.trashedDate)
            case .last7Days:
                let days = Calendar.current.dateComponents([.day], from: item.trashedDate, to: now).day ?? 0
                return days <= 7
            case .last30Days:
                let days = Calendar.current.dateComponents([.day], from: item.trashedDate, to: now).day ?? 0
                return days <= 30
            }
        }
    }
}
