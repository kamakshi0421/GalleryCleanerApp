import SwiftUI

public struct HomeView: View {
    @ObservedObject var homeVM: HomeViewModel = .shared
    @ObservedObject var storageManager: StorageManager = .shared
    @ObservedObject var photoService: PhotoLibraryService = .shared
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Storage Card (Matches Screenshot 1)
                    StorageCardView(storageManager: storageManager)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Scanning Banner
                    if photoService.isScanning {
                        HStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            Text(photoService.scanStage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.08))
                        )
                        .padding(.horizontal)
                    }
                    
                    // Section 1: Media
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Media")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                ScreenshotsView()
                            } label: {
                                CategoryRowView(
                                    category: .screenshots,
                                    count: homeVM.screenshots.count,
                                    totalBytes: homeVM.screenshotsBytes
                                )
                            }
                            
                            Divider()
                                .padding(.leading, 58)
                            
                            NavigationLink {
                                VideosListView()
                            } label: {
                                CategoryRowView(
                                    category: .videos,
                                    count: homeVM.videos.count,
                                    totalBytes: homeVM.videosBytes
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.appCardBackground)
                                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Section 2: Similars
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Similars")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                SimilarPhotosView()
                            } label: {
                                CategoryRowView(
                                    category: .similarPhotos,
                                    count: homeVM.similarPhotos.count,
                                    totalBytes: homeVM.similarPhotosBytes
                                )
                            }
                            
                            Divider()
                                .padding(.leading, 58)
                            
                            NavigationLink {
                                SimilarVideosView()
                            } label: {
                                CategoryRowView(
                                    category: .similarVideos,
                                    count: homeVM.similarVideos.count,
                                    totalBytes: homeVM.similarVideosBytes
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.appCardBackground)
                                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Section 3: Duplicates
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Duplicates")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                DuplicatePhotosView()
                            } label: {
                                CategoryRowView(
                                    category: .duplicatePhotos,
                                    count: homeVM.duplicatePhotos.count,
                                    totalBytes: homeVM.duplicatePhotosBytes
                                )
                            }
                            
                            Divider()
                                .padding(.leading, 58)
                            
                            NavigationLink {
                                DuplicateVideosView()
                            } label: {
                                CategoryRowView(
                                    category: .duplicateVideos,
                                    count: homeVM.duplicateVideos.count,
                                    totalBytes: homeVM.duplicateVideosBytes
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.appCardBackground)
                                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Section 4: Heavy Storage (Large Videos)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Heavy Storage")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                LargeVideosView()
                            } label: {
                                CategoryRowView(
                                    category: .largeVideos,
                                    count: homeVM.largeVideos.count,
                                    totalBytes: homeVM.largeVideosBytes
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.appCardBackground)
                                .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Gallery Cleaner")
            .refreshable {
                await homeVM.refreshData()
            }
        }
        .task {
            await homeVM.startInitialScan()
        }
    }
}
