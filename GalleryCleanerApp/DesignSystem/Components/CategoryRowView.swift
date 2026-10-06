import SwiftUI

public struct CategoryRowView: View {
    public let category: MediaCategory
    public let count: Int
    public let totalBytes: Int64
    
    public init(category: MediaCategory, count: Int, totalBytes: Int64 = 0) {
        self.category = category
        self.count = count
        self.totalBytes = totalBytes
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(category.iconBackground)
                    .frame(width: 44, height: 44)
                
                Image(systemName: category.systemIcon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(category.iconTint)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(count > 0 ? category.title : category.emptyTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                if count > 0 {
                    let formattedBytes = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
                    Text("\(count) \(count == 1 ? "item" : "items") • \(formattedBytes)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text(category.emptySubtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
