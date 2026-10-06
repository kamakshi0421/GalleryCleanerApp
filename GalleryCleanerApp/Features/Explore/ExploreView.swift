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
            ScrollView {
                VStack(spacing: 16) {
                    if groups.isEmpty {
                        EmptyStateView(
                            icon: "calendar",
                            title: "No Media to Explore",
                            message: "Add photos to your gallery or refresh to review your memories by year.",
                            iconTint: .blue
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(groups) { group in
                            exploreCard(for: group)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .navigationTitle("Explore")
            .fullScreenCover(item: $selectedGroup) { group in
                SwipeReviewView(groupTitle: group.year, items: group.items)
            }
        }
    }
    
    private func exploreCard(for group: YearPhotoGroup) -> some View {
        Button(action: {
            selectedGroup = group
            HapticFeedback.medium()
        }) {
            ZStack(alignment: .leading) {
                // Background Thumbnail / Gradient (Matches Screenshot 2)
                if let rep = group.representativeItem {
                    MediaThumbnailView(
                        item: rep,
                        isSelected: false,
                        showSelectionBadge: false,
                        showSizeBadge: false,
                        cornerRadius: 20
                    )
                    .frame(height: 140)
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(white: 0.2))
                        .frame(height: 140)
                }
                
                // Dark Gradient Overlay for readability
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.65), Color.black.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 140)
                
                // Content
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.year)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(group.items.count) \(group.items.count == 1 ? "item" : "items") • \(group.formattedBytes)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.trailing, 24)
                }
            }
            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
