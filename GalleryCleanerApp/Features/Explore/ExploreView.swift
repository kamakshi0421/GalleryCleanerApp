import SwiftUI

public struct YearPhotoGroup: Identifiable {
    public let id: String
    public let year: String
    public let items: [MediaItem]
    
    public var totalBytes: Int64 {
        items.reduce(0) { $0 + $1.fileSize }
    }
    
    public var formattedBytes: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }
    
    public var representativeItem: MediaItem? {
        items.first
    }
}

public struct ExploreView: View {
    @ObservedObject var photoService: PhotoLibraryService = .shared
    @State private var selectedGroup: YearPhotoGroup? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    public init() {}
    
    public var groups: [YearPhotoGroup] {
        let calendar = Calendar.current
        var dict: [String: [MediaItem]] = [:]
        
        let allItems = photoService.allPhotos
        for item in allItems {
            let year = String(calendar.component(.year, from: item.creationDate))
            dict[year, default: []].append(item)
        }
        
        return dict.map { YearPhotoGroup(id: $0.key, year: $0.key, items: $0.value) }
            .sorted { $0.year > $1.year }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.viewBackground.ignoresSafeArea()
                
                ScrollView {
                    if groups.isEmpty {
                        EmptyStateView(
                            icon: "photo.on.rectangle.angled",
                            title: "No Memories Found",
                            message: "Add photos to your gallery or refresh to review your memories by year.",
                            iconTint: AppTheme.primaryBlue
                        )
                        .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(groups) { group in
                                galleryCard(for: group)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 120) // Clear floating tab bar
                    }
                }
            }
            .navigationTitle("Time Machine")
            #if os(iOS)
            .fullScreenCover(item: $selectedGroup) { group in
                SwipeReviewView(groupTitle: group.year, items: group.items)
            }
            #else
            .sheet(item: $selectedGroup) { group in
                SwipeReviewView(groupTitle: group.year, items: group.items)
            }
            #endif
        }
    }
    
    private func galleryCard(for group: YearPhotoGroup) -> some View {
        Button(action: {
            selectedGroup = group
            HapticFeedback.medium()
        }) {
            ZStack(alignment: .bottomLeading) {
                // Background Image
                if let rep = group.representativeItem {
                    MediaThumbnailView(
                        item: rep,
                        isSelected: false,
                        showSelectionBadge: false,
                        showSizeBadge: false,
                        cornerRadius: 24
                    )
                    .aspectRatio(1, contentMode: .fill) // Make it perfectly square
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(white: 0.2))
                        .aspectRatio(1, contentMode: .fill)
                }
                
                // Vignette / Dark Gradient for Text Readability
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.8), Color.black.opacity(0.0)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                
                // Text Overlay
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.year)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                    
                    Text("\(group.items.count) \(group.items.count == 1 ? "item" : "items")")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(group.formattedBytes)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.accentTeal)
                }
                .padding(16)
                
                // Action Icon (Top Right)
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(12)
                    }
                    Spacer()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.15), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
