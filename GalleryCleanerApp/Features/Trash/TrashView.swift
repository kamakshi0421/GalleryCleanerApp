import SwiftUI

public struct TrashView: View {
    @ObservedObject var trashManager: TrashManager = .shared
    @ObservedObject var photoService: PhotoLibraryService = .shared
    
    @State private var selectedFilter: DateFilterOption = .all
    @State private var showingEmptyConfirmation = false
    @State private var showingPermanentDeleteConfirmation = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.viewBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    customHeader
                    
                    if trashManager.items.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "trash",
                            title: "Trash is Empty",
                            message: "Items you delete will appear here for review before permanent removal.",
                            iconTint: .gray
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Stats Card
                                statsCard
                                
                                // Filters
                                filterRow
                                
                                // Grid
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(filteredItems) { item in
                                        let isSelected = trashManager.selectedItemIds.contains(item.id)
                                        MediaThumbnailView(
                                            item: item.mediaItem,
                                            isSelected: isSelected,
                                            showSelectionBadge: true,
                                            showSizeBadge: false, // Hide size badge to make grid cleaner
                                            cornerRadius: 16
                                        )
                                        .frame(height: 110)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            trashManager.toggleSelection(for: item.id)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 160) // Bottom padding for floating bar
                            }
                            .padding(.top, 16)
                        }
                    }
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .overlay(alignment: .bottom) {
                if !trashManager.selectedItemIds.isEmpty {
                    floatingActionBar
                }
            }
            // Confirmation Dialogs
            .confirmationDialog(
                "Empty Trash?",
                isPresented: $showingEmptyConfirmation,
                titleVisibility: .visible
            ) {
                Button("Permanently Delete All", role: .destructive) {
                    Task { await trashManager.emptyAll(photoService: photoService) }
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
                    Task { await trashManager.deleteSelectedPermanently(photoService: photoService) }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Selected items will be permanently removed.")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var customHeader: some View {
        HStack {
            Text("Recovery Bin")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            if !trashManager.items.isEmpty {
                Button(action: { showingEmptyConfirmation = true }) {
                    Text("Empty All")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.accentRed)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var statsCard: some View {
        let allFilteredSelected = (filteredItems.count > 0 && trashManager.selectedItemIds.count == filteredItems.count)
        let totalReclaimableBytes = filteredItems.reduce(0) { $0 + $1.mediaItem.fileSize }
        
        return VStack(spacing: 16) {
            HStack(alignment: .center) {
                ZStack {
                    Circle().fill(AppTheme.accentPink.opacity(0.15)).frame(width: 56, height: 56)
                    Image(systemName: "trash.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.accentPink)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(filteredItems.count) Items")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(ByteCountFormatter.string(fromByteCount: totalReclaimableBytes, countStyle: .file)) reclaimable space")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.accentPink)
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            
            Divider()
            
            Button(action: {
                trashManager.selectAll(visibleIds: filteredItems.map { $0.id })
            }) {
                HStack {
                    Image(systemName: allFilteredSelected ? "checkmark.circle.fill" : "circle.dashed")
                        .foregroundColor(allFilteredSelected ? AppTheme.primaryBlue : .secondary)
                    Text(allFilteredSelected ? "Deselect All" : "Select All")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(allFilteredSelected ? AppTheme.primaryBlue : .primary)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appCardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 12, y: 6)
        )
        .padding(.horizontal, 20)
    }
    
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DateFilterOption.allCases) { filter in
                    let isSelected = (selectedFilter == filter)
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedFilter = filter
                            HapticFeedback.selection()
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                isSelected ? AppTheme.primaryBlue : Color.appSystemGray5
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var floatingActionBar: some View {
        HStack(spacing: 0) {
            // Restore Side
            Button(action: { trashManager.restoreSelected() }) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 18, weight: .bold))
                    Text("Restore")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.primaryBlue)
            }
            
            // Delete Side
            Button(action: { showingPermanentDeleteConfirmation = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .bold))
                    Text("Delete")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.accentRed)
            }
        }
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.2), radius: 15, y: 8)
        .padding(.horizontal, 40)
        .padding(.bottom, 100) // Clear iOS 18 floating tab bar
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
