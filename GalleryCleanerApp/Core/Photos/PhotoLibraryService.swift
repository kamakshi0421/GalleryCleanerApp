import Foundation
import Photos
import UIKit
import Combine

@MainActor
public final class PhotoLibraryService: ObservableObject {
    public static let shared = PhotoLibraryService()
    
    @Published public var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published public var isScanning: Bool = false
    @Published public var scanProgress: Double = 0.0
    @Published public var scanStage: String = "Ready"
    
    @Published public var screenshots: [MediaItem] = []
    @Published public var videos: [MediaItem] = []
    @Published public var allPhotos: [MediaItem] = []
    @Published public var isUsingMockData: Bool = false
    
    public let imageManager = PHCachingImageManager()
    
    private init() {
        self.authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    public func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        self.authorizationStatus = status
        
        switch status {
        case .authorized, .limited:
            await loadLibrary()
            return true
        default:
            loadMockDataIfNeeded()
            return false
        }
    }
    
    public func loadLibrary() async {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            loadMockDataIfNeeded()
            return
        }
        
        isScanning = true
        scanProgress = 0.1
        scanStage = "Scanning photo library..."
        
        let (fetchedScreenshots, fetchedVideos, fetchedPhotos) = await Task.detached(priority: .userInitiated) {
            // Fetch Screenshots
            let screenshotOptions = PHFetchOptions()
            screenshotOptions.predicate = NSPredicate(
                format: "mediaType == %d AND (mediaSubtype & %d) != 0",
                PHAssetMediaType.image.rawValue,
                PHAssetMediaSubtype.photoScreenshot.rawValue
            )
            screenshotOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let screenshotAssets = PHAsset.fetchAssets(with: screenshotOptions)
            
            var screenshotsList: [MediaItem] = []
            screenshotAssets.enumerateObjects { asset, _, _ in
                screenshotsList.append(MediaItem(
                    id: asset.localIdentifier,
                    mediaType: .screenshot,
                    creationDate: asset.creationDate ?? Date(),
                    pixelWidth: asset.pixelWidth,
                    pixelHeight: asset.pixelHeight,
                    fileSize: asset.resourceFileSize,
                    duration: 0
                ))
            }
            
            // Fetch Videos
            let videoOptions = PHFetchOptions()
            videoOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            videoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let videoAssets = PHAsset.fetchAssets(with: videoOptions)
            
            var videosList: [MediaItem] = []
            videoAssets.enumerateObjects { asset, _, _ in
                videosList.append(MediaItem(
                    id: asset.localIdentifier,
                    mediaType: .video,
                    creationDate: asset.creationDate ?? Date(),
                    pixelWidth: asset.pixelWidth,
                    pixelHeight: asset.pixelHeight,
                    fileSize: asset.resourceFileSize,
                    duration: asset.duration
                ))
            }
            
            // Fetch All Photos (including regular photos for duplicate & similarity analysis)
            let photoOptions = PHFetchOptions()
            photoOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let photoAssets = PHAsset.fetchAssets(with: photoOptions)
            
            var photosList: [MediaItem] = []
            photoAssets.enumerateObjects { asset, _, _ in
                let isScreenshot = asset.mediaSubtypes.contains(.photoScreenshot)
                photosList.append(MediaItem(
                    id: asset.localIdentifier,
                    mediaType: isScreenshot ? .screenshot : .photo,
                    creationDate: asset.creationDate ?? Date(),
                    pixelWidth: asset.pixelWidth,
                    pixelHeight: asset.pixelHeight,
                    fileSize: asset.resourceFileSize,
                    duration: 0
                ))
            }
            
            return (screenshotsList, videosList, photosList)
        }.value
        
        self.screenshots = fetchedScreenshots
        self.videos = fetchedVideos
        self.allPhotos = fetchedPhotos
        self.isScanning = false
        self.scanProgress = 1.0
        self.scanStage = "Completed"
        
        // If library is completely empty (like fresh Simulator), populate sample demo items
        if fetchedScreenshots.isEmpty && fetchedVideos.isEmpty && fetchedPhotos.isEmpty {
            loadMockDataIfNeeded()
        } else {
            self.isUsingMockData = false
        }
    }
    
    public func deleteAssets(identifiers: [String]) async throws {
        if isUsingMockData {
            // Remove from mock lists
            let idSet = Set(identifiers)
            self.screenshots.removeAll { idSet.contains($0.id) }
            self.videos.removeAll { idSet.contains($0.id) }
            self.allPhotos.removeAll { idSet.contains($0.id) }
            return
        }
        
        let assetsToDelete = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        guard assetsToDelete.count > 0 else { return }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assetsToDelete)
        }
        
        // Remove locally after deletion
        let idSet = Set(identifiers)
        self.screenshots.removeAll { idSet.contains($0.id) }
        self.videos.removeAll { idSet.contains($0.id) }
        self.allPhotos.removeAll { idSet.contains($0.id) }
    }
    
    /// Generates high quality mock gallery data matching the reference screenshots
    public func loadMockDataIfNeeded() {
        self.isUsingMockData = true
        let calendar = Calendar.current
        let now = Date()
        
        // Generate mock Screenshots
        var mockScreens: [MediaItem] = []
        for i in 1...6 {
            let date = calendar.date(byAdding: .hour, value: -i * 8, to: now) ?? now
            mockScreens.append(MediaItem(
                id: "mock_screen_\(i)",
                mediaType: .screenshot,
                creationDate: date,
                pixelWidth: 1179,
                pixelHeight: 2556,
                fileSize: Int64(1_800_000 + i * 450_000),
                duration: 0,
                mockColorHex: "#38B6FF",
                mockTitle: "Receipt / Screenshot #\(i)"
            ))
        }
        self.screenshots = mockScreens
        
        // Generate mock Videos (varied sizes for Large Videos)
        var mockVids: [MediaItem] = []
        let videoSizes: [Int64] = [
            1_450_000_000, // 1.45 GB
            890_000_000,   // 890 MB
            540_000_000,   // 540 MB
            320_000_000,   // 320 MB
            180_000_000,   // 180 MB
            75_000_000,    // 75 MB
            320_000_000    // Exact duplicate video of #4!
        ]
        let videoDurations: [TimeInterval] = [285, 142, 98, 64, 45, 18, 64]
        
        for (index, size) in videoSizes.enumerated() {
            let date = calendar.date(byAdding: .day, value: -index * 2, to: now) ?? now
            let isDup = (index == 6)
            mockVids.append(MediaItem(
                id: "mock_vid_\(index + 1)",
                mediaType: .video,
                creationDate: date,
                pixelWidth: 3840,
                pixelHeight: 2160,
                fileSize: size,
                duration: videoDurations[index],
                mockColorHex: isDup ? "#9B51E0" : "#E056FD",
                mockTitle: isDup ? "4K Travel Clip (Duplicate)" : "Vacation 4K Recording #\(index + 1)"
            ))
        }
        self.videos = mockVids
        
        // Generate mock Photos (with duplicates & similar photo clusters across years)
        var mockPhotosList: [MediaItem] = []
        
        // Cluster 1: Exact Duplicates (3 copies of same photo)
        let dupDate = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        for copyIndex in 1...3 {
            mockPhotosList.append(MediaItem(
                id: "mock_dup_photo_\(copyIndex)",
                mediaType: .photo,
                creationDate: dupDate,
                pixelWidth: 4032,
                pixelHeight: 3024,
                fileSize: 4_200_000,
                duration: 0,
                mockColorHex: "#FF6B6B",
                mockTitle: "Waterfall Landscape"
            ))
        }
        
        // Cluster 2: Similar Photos (Burst shots taken 2 seconds apart)
        for similarIndex in 1...3 {
            let simDate = calendar.date(byAdding: .second, value: similarIndex * 2, to: dupDate) ?? now
            mockPhotosList.append(MediaItem(
                id: "mock_sim_photo_\(similarIndex)",
                mediaType: .photo,
                creationDate: simDate,
                pixelWidth: 4032,
                pixelHeight: 3024,
                fileSize: Int64(3_800_000 + similarIndex * 150_000),
                duration: 0,
                mockColorHex: "#4E65FF",
                mockTitle: "Beach Sunset Shot \(similarIndex)"
            ))
        }
        
        // Explore Year Mock Photos (2012, 2011, 2009) matching Screenshot 2
        var dateComponents2012 = DateComponents()
        dateComponents2012.year = 2012
        dateComponents2012.month = 8
        dateComponents2012.day = 14
        let date2012 = calendar.date(from: dateComponents2012) ?? now
        for i in 1...3 {
            mockPhotosList.append(MediaItem(
                id: "mock_2012_\(i)",
                mediaType: .photo,
                creationDate: date2012,
                pixelWidth: 3264,
                pixelHeight: 2448,
                fileSize: Int64(1_860_000),
                duration: 0,
                mockColorHex: "#2ECC71",
                mockTitle: "Waterfall Iceland \(i)"
            ))
        }
        
        var dateComponents2011 = DateComponents()
        dateComponents2011.year = 2011
        dateComponents2011.month = 6
        dateComponents2011.day = 10
        let date2011 = calendar.date(from: dateComponents2011) ?? now
        mockPhotosList.append(MediaItem(
            id: "mock_2011_1",
            mediaType: .photo,
            creationDate: date2011,
            pixelWidth: 2592,
            pixelHeight: 1936,
            fileSize: 1_900_000,
            duration: 0,
            mockColorHex: "#F1C40F",
            mockTitle: "Yellow Flower Coast"
        ))
        
        var dateComponents2009 = DateComponents()
        dateComponents2009.year = 2009
        dateComponents2009.month = 4
        dateComponents2009.day = 22
        let date2009 = calendar.date(from: dateComponents2009) ?? now
        mockPhotosList.append(MediaItem(
            id: "mock_2009_1",
            mediaType: .photo,
            creationDate: date2009,
            pixelWidth: 2048,
            pixelHeight: 1536,
            fileSize: 2_600_000,
            duration: 0,
            mockColorHex: "#27AE60",
            mockTitle: "Sunlit Leaves"
        ))
        
        self.allPhotos = mockPhotosList
    }
}
