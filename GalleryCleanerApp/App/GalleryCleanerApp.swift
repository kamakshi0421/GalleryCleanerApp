import SwiftUI

@main
struct GalleryCleanerApp: App {
    @StateObject private var photoService = PhotoLibraryService.shared
    @StateObject private var storageManager = StorageManager.shared
    @StateObject private var trashManager = TrashManager.shared
    @StateObject private var homeVM = HomeViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(photoService)
                .environmentObject(storageManager)
                .environmentObject(trashManager)
                .environmentObject(homeVM)
        }
    }
}
