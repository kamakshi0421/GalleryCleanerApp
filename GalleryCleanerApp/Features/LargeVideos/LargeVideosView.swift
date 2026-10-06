import SwiftUI

public struct LargeVideosView: View {
    @ObservedObject var homeVM: HomeViewModel = .shared
    @ObservedObject var trashManager: TrashManager = .shared
    @ObservedObject var photoService: PhotoLibraryService = .shared
    
    @State private var selectedIds: Set<String> = []
    @State private var showingConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if homeVM.largeVideos.isEmpty {
                EmptyStateView(
                    icon: "arrow.down.circle.fill",
                    title: "No Large Videos",
                    message: "No videos found taking up heavy storage in your gallery.",
                    iconTint: Color(red: 0.20, green: 0.55, blue: 0.95)
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // Header info
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(homeVM.largeVideos.count) Heavy Videos")
                                    .font(.system(size: 16, weight: .bold))
                                
                                let totalBytes = homeVM.largeVideos.reduce(0) { $0 + $1.fileSize }
                                Text("Sorted biggest first • Total: \(ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(selectedIds.count == homeVM.largeVideos.count ? "Deselect All" : "Select All") {
                                if selectedIds.count == homeVM.largeVideos.count {
                                    selectedIds.removeAll()
                                } else {
                                    selectedIds = Set(homeVM.largeVideos.map { $0.id })
                                }
                                HapticFeedback.selection()
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // Videos List (Ranked biggest first)
                        ForEach(Array(homeVM.largeVideos.enumerated()), id: \.element.id) { index, item in
                            largeVideoRow(index: index + 1, item: item)
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationTitle("Large Videos")
        .appInlineTitle()
        .overlay(alignment: .bottom) {
            if !selectedIds.isEmpty {
                bottomActionBar
            }
        }
    }
    
    private func largeVideoRow(index: Int, item: MediaItem) -> some View {
        let isSelected = selectedIds.contains(item.id)
        
        return HStack(spacing: 12) {
            // Rank Number
            Text("#\(index)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(index <= 3 ? .red : .secondary)
                .frame(width: 28)
            
            // Thumbnail
            ZStack {
                MediaThumbnailView(
                    item: item,
                    isSelected: isSelected,
                    showSelectionBadge: false,
                    showSizeBadge: false,
                    cornerRadius: 10
                )
                .frame(width: 80, height: 80)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.mockTitle ?? "Video File")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if !item.formattedDuration.isEmpty {
                        Label(item.formattedDuration, systemImage: "play.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    if !item.dimensionsString.isEmpty {
                        Text(item.dimensionsString)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Big Size Pill
                Text(item.formattedSize)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(index <= 3 ? .red : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((index <= 3 ? Color.red : Color.blue).opacity(0.12))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            // Checkmark button
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.appSystemGray5)
                    .frame(width: 26, height: 26)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appCardBackground)
                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        )
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedIds.contains(item.id) {
                selectedIds.remove(item.id)
            } else {
                selectedIds.insert(item.id)
            }
            HapticFeedback.selection()
        }
    }
    
    private var bottomActionBar: some View {
        let reclaimBytes = homeVM.largeVideos
            .filter { selectedIds.contains($0.id) }
            .reduce(0) { $0 + $1.fileSize }
        
        return VStack {
            Button(action: {
                showingConfirmation = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                    Text("Clean \(selectedIds.count) Heavy Videos (\(ByteCountFormatter.string(fromByteCount: reclaimBytes, countStyle: .file)))")
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
                colors: [Color.appSystemBackground.opacity(0), Color.appSystemBackground.opacity(0.95), Color.appSystemBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .confirmationDialog(
            "Move Videos to Trash?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clean \(selectedIds.count) Large Videos", role: .destructive) {
                let toMove = homeVM.largeVideos.filter { selectedIds.contains($0.id) }
                trashManager.moveToTrash(items: toMove)
                let idSet = selectedIds
                photoService.videos.removeAll { idSet.contains($0.id) }
                selectedIds.removeAll()
                HapticFeedback.success()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
