import SwiftUI
import Photos

#if canImport(UIKit)
import UIKit
#endif

public struct MediaThumbnailView: View {
    public let item: MediaItem
    public var isSelected: Bool = false
    public var showSelectionBadge: Bool = false
    public var showSizeBadge: Bool = true
    public var cornerRadius: CGFloat = 12
    
    #if canImport(UIKit)
    @State private var loadedImage: UIImage? = nil
    #endif
    
    public init(
        item: MediaItem,
        isSelected: Bool = false,
        showSelectionBadge: Bool = false,
        showSizeBadge: Bool = true,
        cornerRadius: CGFloat = 12
    ) {
        self.item = item
        self.isSelected = isSelected
        self.showSelectionBadge = showSelectionBadge
        self.showSizeBadge = showSizeBadge
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        ZStack {
            // Image Content
            #if canImport(UIKit)
            if let uiImage = loadedImage {
                GeometryReader { geo in
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            } else {
                placeholderView
            }
            #else
            placeholderView
            #endif
            
            // Top Right Selection Badge (Matches Screenshot 5)
            if showSelectionBadge {
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.blue : Color.black.opacity(0.35))
                                .frame(width: 22, height: 22)
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(6)
                    }
                    Spacer()
                }
            }
            
            // Video Duration Badge (Top Left)
            if item.isVideo && !item.formattedDuration.isEmpty {
                VStack {
                    HStack {
                        HStack(spacing: 3) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 8))
                            Text(item.formattedDuration)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.65))
                        .clipShape(Capsule())
                        .padding(6)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            // Bottom Right Size Badge (Matches Screenshot 5)
            if showSizeBadge && item.fileSize > 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(item.formattedSize)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(Color.black.opacity(0.70))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(6)
                    }
                }
            }
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onAppear {
            loadThumbnail()
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            let baseColor = Color(hex: item.mockColorHex ?? "#4A90E2")
            LinearGradient(
                colors: [baseColor, baseColor.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 6) {
                Image(systemName: item.isVideo ? "video.fill" : (item.isScreenshot ? "crop" : "photo.fill"))
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.85))
                
                if let title = item.mockTitle {
                    Text(title)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                        .lineLimit(2)
                }
            }
        }
    }
    
    private func loadThumbnail() {
        #if canImport(UIKit)
        guard let id = item.assetLocalIdentifier, !id.hasPrefix("mock_") else {
            return
        }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = assets.firstObject else { return }
        
        let targetSize = CGSize(width: 250, height: 250)
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            if let image = image {
                self.loadedImage = image
            }
        }
        #endif
    }
}

// Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 66, 133, 244)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
