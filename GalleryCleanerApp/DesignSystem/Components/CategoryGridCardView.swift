import SwiftUI

public struct CategoryGridCardView: View {
    public let category: MediaCategory
    public let count: Int
    public let totalBytes: Int64
    
    public init(category: MediaCategory, count: Int, totalBytes: Int64 = 0) {
        self.category = category
        self.count = count
        self.totalBytes = totalBytes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(category.iconBackground)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: category.systemIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(category.iconTint)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.appTertiaryLabel)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(count > 0 ? category.title : category.emptyTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if count > 0 {
                    let formattedBytes = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
                    Text("\(count) items • \(formattedBytes)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Clean")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appCardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .contentShape(Rectangle())
    }
}
