import Foundation
import SwiftUI
import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    public static let shared = HomeViewModel()
    
    @Published public var analysisState: AnalysisState = .idle
    @Published public var duplicatePhotos: [DuplicateGroup] = []
    @Published public var similarPhotos: [SimilarGroup] = []
    @Published public var duplicateVideos: [DuplicateGroup] = []
    @Published public var similarVideos: [SimilarGroup] = []
    @Published public var largeVideos: [MediaItem] = []
    
    private let photoService: PhotoLibraryService
    private let duplicateDetector: DuplicateDetector
    private let similarityEngine: SimilarityEngine
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    public init(
        photoService: PhotoLibraryService? = nil,
        duplicateDetector: DuplicateDetector = .shared,
        similarityEngine: SimilarityEngine = .shared
    ) {
        let service = photoService ?? .shared
        self.photoService = service
        self.duplicateDetector = duplicateDetector
        self.similarityEngine = similarityEngine
        
        // Observe photo service changes
        service.$allPhotos
            .combineLatest(service.$videos)
            .sink { [weak self] photos, videos in
                Task { [weak self] in
                    await self?.runAnalysis(photos: photos, videos: videos)
                }
            }
            .store(in: &cancellables)
    }
    
    public var screenshots: [MediaItem] {
        photoService.screenshots
    }
    
    public var videos: [MediaItem] {
        photoService.videos
    }
    
    public var screenshotsBytes: Int64 {
        screenshots.reduce(0) { $0 + $1.fileSize }
    }
    
    public var videosBytes: Int64 {
        videos.reduce(0) { $0 + $1.fileSize }
    }
    
    public var duplicatePhotosBytes: Int64 {
        duplicatePhotos.reduce(0) { $0 + $1.reclaimableSpace }
    }
    
    public var similarPhotosBytes: Int64 {
        similarPhotos.reduce(0) { $0 + $1.reclaimableSpace }
    }
    
    public var duplicateVideosBytes: Int64 {
        duplicateVideos.reduce(0) { $0 + $1.reclaimableSpace }
    }
    
    public var similarVideosBytes: Int64 {
        similarVideos.reduce(0) { $0 + $1.reclaimableSpace }
    }
    
    public var largeVideosBytes: Int64 {
        largeVideos.reduce(0) { $0 + $1.fileSize }
    }
    
    public func startInitialScan() async {
        analysisState = .scanning(progress: 0.1, stage: "Checking gallery access...")
        let authorized = await photoService.requestAuthorization()
        if !authorized {
            photoService.loadMockDataIfNeeded()
        }
    }
    
    public func refreshData() async {
        await photoService.loadLibrary()
    }
    
    private func runAnalysis(photos: [MediaItem], videos: [MediaItem]) async {
        guard !photos.isEmpty || !videos.isEmpty else { return }
        
        analysisState = .scanning(progress: 0.3, stage: "Detecting duplicate photos...")
        let dupsPhotos = await duplicateDetector.findDuplicatePhotos(from: photos)
        
        analysisState = .scanning(progress: 0.5, stage: "Analyzing photo similarities...")
        let simPhotos = await similarityEngine.findSimilarPhotos(from: photos)
        
        analysisState = .scanning(progress: 0.7, stage: "Checking duplicate videos...")
        let dupsVideos = await duplicateDetector.findDuplicateVideos(from: videos)
        let simVideos = await similarityEngine.findSimilarVideos(from: videos)
        
        analysisState = .scanning(progress: 0.9, stage: "Sorting large videos...")
        // Requirement 6: "Large Videos shows the videos that take up the most storage, biggest first."
        let sortedLargeVideos = videos.sorted { $0.fileSize > $1.fileSize }
        
        self.duplicatePhotos = dupsPhotos
        self.similarPhotos = simPhotos
        self.duplicateVideos = dupsVideos
        self.similarVideos = simVideos
        self.largeVideos = sortedLargeVideos
        self.analysisState = .completed
    }
}
