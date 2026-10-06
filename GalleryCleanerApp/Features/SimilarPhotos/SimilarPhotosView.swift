import SwiftUI

public struct SimilarPhotosView: View {
    @ObservedObject var homeVM: HomeViewModel = .shared
    @ObservedObject var trashManager: TrashManager = .shared
    @ObservedObject var photoService: PhotoLibraryService = .shared
    
    @State private var selectedDeleteIds: Set<String> = []
    @State private var showingConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if homeVM.similarPhotos.isEmpty {
                EmptyStateView(
                    icon: "photo.on.rectangle.angled",
                    title: "No Similar Photos",
                    message: "No bursts or lookalike photos found! Your photo library is already curated.",
                    iconTint: Color(red: 0.96, green: 0.35, blue: 0.45)
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Summary Banner
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(homeVM.similarPhotos.count) Similar Photo Groups")
                                    .font(.system(size: 16, weight: .bold))
                                
                                let totalReclaim = homeVM.similarPhotos.reduce(0) { $0 + $1.reclaimableSpace }
                                Text("Reclaimable space: \(ByteCountFormatter.string(fromByteCount: totalReclaim, countStyle: .file))")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(allInferiorSelected ? "Deselect All" : "Auto-Select Inferior") {
                                toggleAutoSelect()
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // Groups
                        ForEach(Array(homeVM.similarPhotos.enumerated()), id: \.element.id) { index, group in
                            similarGroupCard(index: index + 1, group: group)
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationTitle("Similar Photos")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            autoSelectInferior()
        }
        .overlay(alignment: .bottom) {
            if !selectedDeleteIds.isEmpty {
                bottomActionBar
            }
        }
    }
    
    private var allInferiorSelected: Bool {
        let inferiors = homeVM.similarPhotos.flatMap { $0.removableItems }.map { $0.id }
        return !inferiors.isEmpty && selectedDeleteIds.count == inferiors.count
    }
    
    private func autoSelectInferior() {
        let inferiors = homeVM.similarPhotos.flatMap { $0.removableItems }.map { $0.id }
        selectedDeleteIds = Set(inferiors)
    }
    
    private func toggleAutoSelect() {
        if allInferiorSelected {
            selectedDeleteIds.removeAll()
        } else {
            autoSelectInferior()
        }
        HapticFeedback.selection()
    }
    
    private func similarGroupCard(index: Int, group: SimilarGroup) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Group \(index) • \(group.formattedScore)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(group.formattedReclaimableSpace) reclaimable")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.pink)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(group.items) { item in
                        let isBest = (item.id == group.bestItem?.id)
                        let isSelected = selectedDeleteIds.contains(item.id)
                        
                        VStack(spacing: 6) {
                            ZStack(alignment: .topLeading) {
                                MediaThumbnailView(
                                    item: item,
                                    isSelected: isSelected,
                                    showSelectionBadge: !isBest,
                                    showSizeBadge: true,
                                    cornerRadius: 10
                                )
                                .frame(width: 130, height: 130)
                                
                                if isBest {
                                    Text("BEST")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                        .padding(6)
                                }
                            }
                            
                            Text(isBest ? "Best Shot" : "Similar")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(isBest ? .blue : .secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isBest {
                                if selectedDeleteIds.contains(item.id) {
                                    selectedDeleteIds.remove(item.id)
                                } else {
                                    selectedDeleteIds.insert(item.id)
                                }
                                HapticFeedback.selection()
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var bottomActionBar: some View {
        let reclaimBytes = homeVM.similarPhotos
            .flatMap { $0.items }
            .filter { selectedDeleteIds.contains($0.id) }
            .reduce(0) { $0 + $1.fileSize }
        
        return VStack {
            Button(action: {
                showingConfirmation = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                    Text("Clean \(selectedDeleteIds.count) Similar (\(ByteCountFormatter.string(fromByteCount: reclaimBytes, countStyle: .file)))")
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
            Button("Clean \(selectedDeleteIds.count) Similar Photos", role: .destructive) {
                let toMove = homeVM.similarPhotos
                    .flatMap { $0.items }
                    .filter { selectedDeleteIds.contains($0.id) }
                
                trashManager.moveToTrash(items: toMove)
                
                let idSet = selectedDeleteIds
                photoService.allPhotos.removeAll { idSet.contains($0.id) }
                selectedDeleteIds.removeAll()
                HapticFeedback.success()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
