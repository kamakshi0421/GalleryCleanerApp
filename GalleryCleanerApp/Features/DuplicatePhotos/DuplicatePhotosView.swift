import SwiftUI

public struct DuplicatePhotosView: View {
    @ObservedObject var homeVM: HomeViewModel = .shared
    @ObservedObject var trashManager: TrashManager = .shared
    @ObservedObject var photoService: PhotoLibraryService = .shared
    
    @State private var selectedDuplicateIds: Set<String> = []
    @State private var showingConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            if homeVM.duplicatePhotos.isEmpty {
                EmptyStateView(
                    icon: "doc.on.doc.fill",
                    title: "No Duplicate Photos",
                    message: "No exact duplicate photos found! Your photo library is well-organized.",
                    iconTint: Color(red: 0.98, green: 0.55, blue: 0.20)
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Summary Banner
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(homeVM.duplicatePhotos.count) Duplicate Sets Found")
                                    .font(.system(size: 16, weight: .bold))
                                
                                let totalReclaim = homeVM.duplicatePhotos.reduce(0) { $0 + $1.reclaimableSpace }
                                Text("Reclaimable space: \(ByteCountFormatter.string(fromByteCount: totalReclaim, countStyle: .file))")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(allDuplicatesSelected ? "Deselect All" : "Auto-Select Duplicates") {
                                toggleAutoSelect()
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // Duplicate Groups List
                        ForEach(Array(homeVM.duplicatePhotos.enumerated()), id: \.element.id) { index, group in
                            duplicateGroupCard(index: index + 1, group: group)
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        .navigationTitle("Duplicate Photos")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            autoSelectDefaultDuplicates()
        }
        .overlay(alignment: .bottom) {
            if !selectedDuplicateIds.isEmpty {
                bottomActionBar
            }
        }
    }
    
    private var allDuplicatesSelected: Bool {
        let allDups = homeVM.duplicatePhotos.flatMap { $0.duplicateItems }.map { $0.id }
        return !allDups.isEmpty && selectedDuplicateIds.count == allDups.count
    }
    
    private func autoSelectDefaultDuplicates() {
        let dups = homeVM.duplicatePhotos.flatMap { $0.duplicateItems }.map { $0.id }
        selectedDuplicateIds = Set(dups)
    }
    
    private func toggleAutoSelect() {
        if allDuplicatesSelected {
            selectedDuplicateIds.removeAll()
        } else {
            autoSelectDefaultDuplicates()
        }
        HapticFeedback.selection()
    }
    
    private func duplicateGroupCard(index: Int, group: DuplicateGroup) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Set \(index) • \(group.items.count) exact copies")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(group.formattedReclaimableSpace) reclaimable")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(group.items.enumerated()), id: \.element.id) { itemIndex, item in
                        let isOriginal = (itemIndex == 0)
                        let isSelected = selectedDuplicateIds.contains(item.id)
                        
                        VStack(spacing: 6) {
                            ZStack(alignment: .topLeading) {
                                MediaThumbnailView(
                                    item: item,
                                    isSelected: isSelected,
                                    showSelectionBadge: !isOriginal,
                                    showSizeBadge: true,
                                    cornerRadius: 10
                                )
                                .frame(width: 130, height: 130)
                                
                                if isOriginal {
                                    Text("KEEP")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(Color.green)
                                        .clipShape(Capsule())
                                        .padding(6)
                                }
                            }
                            
                            Text(isOriginal ? "Original" : "Duplicate")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(isOriginal ? .green : .secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isOriginal {
                                if selectedDuplicateIds.contains(item.id) {
                                    selectedDuplicateIds.remove(item.id)
                                } else {
                                    selectedDuplicateIds.insert(item.id)
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
        let reclaimBytes = homeVM.duplicatePhotos
            .flatMap { $0.items }
            .filter { selectedDuplicateIds.contains($0.id) }
            .reduce(0) { $0 + $1.fileSize }
        
        return VStack {
            Button(action: {
                showingConfirmation = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                    Text("Clean \(selectedDuplicateIds.count) Duplicates (\(ByteCountFormatter.string(fromByteCount: reclaimBytes, countStyle: .file)))")
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
            "Move Duplicates to Trash?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clean \(selectedDuplicateIds.count) Duplicates", role: .destructive) {
                let toMove = homeVM.duplicatePhotos
                    .flatMap { $0.items }
                    .filter { selectedDuplicateIds.contains($0.id) }
                
                trashManager.moveToTrash(items: toMove)
                
                let idSet = selectedDuplicateIds
                photoService.allPhotos.removeAll { idSet.contains($0.id) }
                selectedDuplicateIds.removeAll()
                HapticFeedback.success()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
