import SwiftUI

public struct ScreenshotsView: View {
    @ObservedObject var photoService: PhotoLibraryService = .shared
    @ObservedObject var trashManager: TrashManager = .shared
    
    @State private var isSelectionMode: Bool = false
    @State private var selectedIds: Set<String> = []
    @State private var showingConfirmation: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if photoService.screenshots.isEmpty {
                EmptyStateView(
                    icon: "crop",
                    title: "No Screenshots",
                    message: "Your gallery is screenshot-free! When you take screenshots, they will appear here.",
                    iconTint: Color(red: 0.15, green: 0.65, blue: 0.95)
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // Header info
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(photoService.screenshots.count) Screenshots")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                let totalBytes = photoService.screenshots.reduce(0) { $0 + $1.fileSize }
                                Text("Taking up \(ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if isSelectionMode {
                                Button(selectedIds.count == photoService.screenshots.count ? "Deselect All" : "Select All") {
                                    if selectedIds.count == photoService.screenshots.count {
                                        selectedIds.removeAll()
                                    } else {
                                        selectedIds = Set(photoService.screenshots.map { $0.id })
                                    }
                                    HapticFeedback.selection()
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // Grid
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(photoService.screenshots) { item in
                                ZStack {
                                    MediaThumbnailView(
                                        item: item,
                                        isSelected: selectedIds.contains(item.id),
                                        showSelectionBadge: isSelectionMode,
                                        showSizeBadge: true
                                    )
                                    .frame(height: 140)
                                }
                                .onTapGesture {
                                    if isSelectionMode {
                                        if selectedIds.contains(item.id) {
                                            selectedIds.remove(item.id)
                                        } else {
                                            selectedIds.insert(item.id)
                                        }
                                        HapticFeedback.selection()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationTitle("Screenshots")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !photoService.screenshots.isEmpty {
                    Button(isSelectionMode ? "Done" : "Select") {
                        withAnimation {
                            isSelectionMode.toggle()
                            if !isSelectionMode {
                                selectedIds.removeAll()
                            }
                        }
                        HapticFeedback.light()
                    }
                    .font(.system(size: 15, weight: .semibold))
                }
            }
        }
        .overlay(alignment: .bottom) {
            if isSelectionMode && !selectedIds.isEmpty {
                bottomActionBar
            }
        }
    }
    
    private var bottomActionBar: some View {
        let reclaimBytes = photoService.screenshots
            .filter { selectedIds.contains($0.id) }
            .reduce(0) { $0 + $1.fileSize }
        
        return VStack {
            Button(action: {
                showingConfirmation = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                    Text("Move \(selectedIds.count) to Trash (\(ByteCountFormatter.string(fromByteCount: reclaimBytes, countStyle: .file)))")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red)
                .clipShape(Capsule())
                .shadow(color: Color.red.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(
            LinearGradient(
                colors: [Color(UIColor.systemBackground).opacity(0), Color(UIColor.systemBackground).opacity(0.95), Color(UIColor.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .confirmationDialog(
            "Move to Trash?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Move \(selectedIds.count) Items to Trash", role: .destructive) {
                let toMove = photoService.screenshots.filter { selectedIds.contains($0.id) }
                trashManager.moveToTrash(items: toMove)
                let idSet = selectedIds
                photoService.screenshots.removeAll { idSet.contains($0.id) }
                selectedIds.removeAll()
                isSelectionMode = false
                HapticFeedback.success()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("These items will be moved to the in-app Trash where you can review, restore, or delete them permanently.")
        }
    }
}
