import SwiftUI

public enum MediaCategory: String, CaseIterable, Identifiable, Sendable {
    case screenshots
    case videos
    case similarPhotos
    case similarVideos
    case duplicatePhotos
    case duplicateVideos
    case largeVideos
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .screenshots: return "Screenshots"
        case .videos: return "Videos"
        case .similarPhotos: return "Similar Photos"
        case .similarVideos: return "Similar Videos"
        case .duplicatePhotos: return "Duplicate Photos"
        case .duplicateVideos: return "Duplicate Videos"
        case .largeVideos: return "Large Videos"
        }
    }
    
    public var emptyTitle: String {
        switch self {
        case .screenshots: return "No Screenshots"
        case .videos: return "No Videos"
        case .similarPhotos: return "No Similar Photos"
        case .similarVideos: return "No Similar Videos"
        case .duplicatePhotos: return "No Duplicate Photos"
        case .duplicateVideos: return "No Duplicate Videos"
        case .largeVideos: return "No Large Videos"
        }
    }
    
    public var emptySubtitle: String {
        switch self {
        case .screenshots:
            return "We will automatically find new screenshots if you take more."
        case .videos:
            return "No video files found in your gallery."
        case .similarPhotos:
            return "We will automatically group similar photos if you have more."
        case .similarVideos:
            return "We will automatically find visually similar videos."
        case .duplicatePhotos:
            return "No identical duplicate photos found."
        case .duplicateVideos:
            return "No duplicate video files detected."
        case .largeVideos:
            return "No large video files found."
        }
    }
    
    public var systemIcon: String {
        switch self {
        case .screenshots: return "crop"
        case .videos: return "video.fill"
        case .similarPhotos: return "photo.on.rectangle.angled"
        case .similarVideos: return "film"
        case .duplicatePhotos: return "doc.on.doc.fill"
        case .duplicateVideos: return "rectangle.stack.badge.play"
        case .largeVideos: return "arrow.down.circle.fill"
        }
    }
    
    public var iconTint: Color {
        switch self {
        case .screenshots: return Color(red: 0.15, green: 0.65, blue: 0.95)
        case .videos: return Color(red: 0.88, green: 0.28, blue: 0.75)
        case .similarPhotos: return Color(red: 0.96, green: 0.35, blue: 0.45)
        case .similarVideos: return Color(red: 0.18, green: 0.75, blue: 0.72)
        case .duplicatePhotos: return Color(red: 0.98, green: 0.55, blue: 0.20)
        case .duplicateVideos: return Color(red: 0.45, green: 0.40, blue: 0.92)
        case .largeVideos: return Color(red: 0.20, green: 0.55, blue: 0.95)
        }
    }
    
    public var iconBackground: Color {
        iconTint.opacity(0.12)
    }
}
