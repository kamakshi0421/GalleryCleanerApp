import SwiftUI

@MainActor
public struct HomeView: View {
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var storageManager = StorageManager.shared
    @StateObject private var photoService = PhotoLibraryService.shared
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppTheme.viewBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Storage overview
                        StorageCardView(storageManager: storageManager)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Status
                        if photoService.isScanning {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primaryBlue))
                                Text(photoService.scanStage)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.primaryBlue)
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.primaryBlue.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Dashboard Grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Clean Up")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                // Duplicates
                                NavigationLink {
                                    DuplicatePhotosView()
                                } label: {
                                    CategoryGridCardView(
                                        category: .duplicatePhotos,
                                        count: homeVM.duplicatePhotos.count,
                                        totalBytes: homeVM.duplicatePhotosBytes
                                    )
                                }
                                
                                NavigationLink {
                                    DuplicateVideosView()
                                } label: {
                                    CategoryGridCardView(
                                        category: .duplicateVideos,
                                        count: homeVM.duplicateVideos.count,
                                        totalBytes: homeVM.duplicateVideosBytes
                                    )
                                }
                                
                                // Similars
                                NavigationLink {
                                    SimilarPhotosView()
                                } label: {
                                    CategoryGridCardView(
                                        category: .similarPhotos,
                                        count: homeVM.similarPhotos.count,
                                        totalBytes: homeVM.similarPhotosBytes
                                    )
                                }
                                
                                NavigationLink {
                                    SimilarVideosView()
                                } label: {
                                    CategoryGridCardView(
                                        category: .similarVideos,
                                        count: homeVM.similarVideos.count,
                                        totalBytes: homeVM.similarVideosBytes
                                    )
                                }
                                
                                // Large Media
                                NavigationLink {
                                    LargeVideosView()
                                } label: {
                                    CategoryGridCardView(
                                        category: .largeVideos,
                                        count: homeVM.largeVideos.count,
                                        totalBytes: homeVM.largeVideosBytes
                                    )
                                }
                                
                                // Others (Screenshots)
                                NavigationLink {
                                    ScreenshotsView()
                                } label: {
                                    CategoryGridCardView(
                                        category: .screenshots,
                                        count: homeVM.screenshots.count,
                                        totalBytes: homeVM.screenshotsBytes
                                    )
                                }
                                
                                // Videos
                                NavigationLink {
                                    VideosListView()
                                } label: {
                                    CategoryGridCardView(
                                        category: .videos,
                                        count: homeVM.videos.count,
                                        totalBytes: homeVM.videosBytes
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Dashboard")
            .appInlineTitle()
            .refreshable {
                await homeVM.refreshData()
            }
        }
        .task {
            await homeVM.startInitialScan()
        }
    }
}
