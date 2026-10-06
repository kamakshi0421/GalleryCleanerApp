import Foundation
import Photos
import UIKit

public enum MediaItemType: String, Codable, Sendable {
    case photo
    case video
    case screenshot
}

public struct MediaItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let mediaType: MediaItemType
    public let creationDate: Date
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let fileSize: Int64
    public let duration: TimeInterval
    public let mockColorHex: String?
    public let mockTitle: String?
    
    public var assetLocalIdentifier: String? {
        return id
    }
    
    public init(
        id: String = UUID().uuidString,
        mediaType: MediaItemType,
        creationDate: Date = Date(),
        pixelWidth: Int = 1920,
        pixelHeight: Int = 1080,
        fileSize: Int64 = 0,
        duration: TimeInterval = 0,
        mockColorHex: String? = nil,
        mockTitle: String? = nil
    ) {
        self.id = id
        self.mediaType = mediaType
        self.creationDate = creationDate
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.fileSize = fileSize
        self.duration = duration
        self.mockColorHex = mockColorHex
        self.mockTitle = mockTitle
    }
    
    public var formattedSize: String {
        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    public var formattedDuration: String {
        guard duration > 0 else { return "" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    public var dimensionsString: String {
        guard pixelWidth > 0 && pixelHeight > 0 else { return "" }
        return "\(pixelWidth) × \(pixelHeight)"
    }
    
    public var isVideo: Bool {
        return mediaType == .video
    }
    
    public var isScreenshot: Bool {
        return mediaType == .screenshot
    }
    
    public var isPhoto: Bool {
        return mediaType == .photo
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
}
