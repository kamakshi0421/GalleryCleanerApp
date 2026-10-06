# Gallery Cleaner 📱🧹

A native, high-performance iOS gallery cleaner app built with **SwiftUI**, Apple's **PhotoKit (`Photos`)**, and **Vision** frameworks. Designed to keep devices clean and fast, handling galleries with thousands of items smoothly without freezing.

---

## 🌟 Features Overview

The app reads the device gallery and categorizes media into six essential cleaner options, plus interactive swipe-to-review and trash management:

### 1. 📸 Screenshots
- **Purpose**: Scans and displays all screenshots stored on the device.
- **Capabilities**: Shows capture date, resolution, and exact file size. Supports batch multi-selection, "Select All", and 1-tap move to Trash.

### 2. 🎬 Videos
- **Purpose**: Displays all video files in the gallery.
- **Capabilities**: Displays video duration badge (e.g. `1:42`), file size, and timestamps in an optimized 2-column grid.

### 3. 👯 Duplicate Photos
- **Purpose**: Detects **exact copies** of photos in the gallery.
- **Detection Algorithm**: Matches identical dimensions (`pixelWidth` × `pixelHeight`), exact resource byte size, and content fingerprints.
- **Auto-Selection**: Recommends keeping the best/earliest original with a green **KEEP** badge, while auto-selecting duplicate copies for 1-tap cleaning.

### 4. 🎞️ Duplicate Videos
- **Purpose**: Detects exact copies of video files.
- **Detection Algorithm**: Compares resolution, exact millisecond duration, and file byte size to find duplicate clips.
- **Auto-Selection**: Automatically marks redundant copies for 1-tap cleaning while preserving the original.

### 5. 🔍 Similar Photos
- **Purpose**: Finds photos that look nearly the same (burst shots, multi-take selfies, identical scenes).
- **Detection Algorithm**: Clusters photos taken in close temporal proximity (burst sequences) and computes perceptual aspect ratio & vision feature distances.
- **Best Shot Recommendation**: Automatically highlights the sharpest, highest-resolution picture with a **BEST** badge, allowing easy removal of inferior shots.

### 6. 🐘 Large Videos (Heavy Storage)
- **Purpose**: Identifies the videos taking up the most storage.
- **Sorting**: Strictly ordered **descending by file size (biggest first)**.
- **Badging**: Displays rank badges (`#1`, `#2`, `#3`), duration, resolution, and prominent storage badges for quick reclamation.

---

## 🚀 Additional Highlight Features

- **📊 Device Storage Card**: Live breakdown of device disk space (Used vs. Free GB, percentage badge, and smooth gradient progress bar).
- **🗓️ Explore Tab**: Memories organized by year/period with photo cards and item/storage counts.
- **🃏 Tinder-Style Swipe Reviewer**:
  - Drag Left ➡️ Trashes the item with haptic feedback.
  - Drag Right ➡️ Keeps the item with haptic feedback.
  - Undo button (`􀅌`) to step back and revert decisions.
  - Real-time progress bar and "Saved MB" counter.
  - **Review Complete Dialog**: Celebratory checkmark with summary of Photos Kept, Moved to Trash, and Reclaimable Space.
- **🗑️ Safe Staged Trash**:
  - Filter pills: `All`, `Today`, `Last 7 Days`, `Last 30 Days`.
  - Multi-selection and "Select All".
  - Two-stage safety: `Restore` items back to library or `Delete Permanently`.
  - `Empty All` with confirmation dialog.

---

## ⚡ Performance & Scalability (Smooth with 10,000+ Items)

To satisfy the requirement that **"the app stays smooth with a large gallery (thousands of items), and the screen never freezes while data is loading"**:

1. **Background Asynchronous Concurrency**:
   - Heavy operations (PhotoKit fetching, resource byte calculations, duplicate grouping, and Vision clustering) are performed off the main thread inside `Task.detached(priority: .userInitiated)`.
2. **Zero-Lag UI**:
   - `PHFetchResult` metadata is scanned without downloading full-resolution images into memory.
   - `LazyVGrid` and `LazyVStack` guarantee only visible items are rendered.
3. **Optimized Thumbnail Caching**:
   - Uses `PHCachingImageManager` to opportunistically request lightweight thumbnail representations (`CGSize(width: 250, height: 250)`).
4. **Instant Simulator Fallback**:
   - When launched on a simulator with 0 photos, realistic demo data (screenshots, duplicates, burst shots, 4K heavy videos) is instantly loaded so all flows can be reviewed without manual setup. Real devices automatically query the native PhotoKit library.

---

## 🛠️ Project Structure

```
GalleryCleanerApp/
├── App/
│   └── GalleryCleanerApp.swift          # @main entry point
├── Models/
│   ├── MediaItem.swift                  # Encapsulates PHAsset & metadata
│   ├── MediaCategory.swift              # 6 cleaner categories + icons/tints
│   ├── DuplicateGroup.swift             # Grouping exact duplicates
│   ├── SimilarGroup.swift               # Grouping visually similar burst photos
│   ├── DateFilterOption.swift           # Trash filter pills
│   └── AnalysisState.swift              # Scan state and progress tracking
├── Core/
│   ├── Photos/
│   │   ├── PhotoLibraryService.swift    # PhotoKit integration & background fetch
│   │   └── PHAsset+Extensions.swift     # Size calculation & screenshot helper
│   ├── Analysis/
│   │   ├── DuplicateDetector.swift      # Exact duplicate detection engine
│   │   └── SimilarityEngine.swift       # Perceptual & temporal clustering engine
│   ├── Media/
│   │   ├── StorageManager.swift         # Hardware disk storage metrics
│   │   └── TrashManager.swift           # Staged deletion & restoration
│   └── Utilities/
│       ├── FileSizeFormatter.swift      # Byte size formatting
│       └── HapticFeedback.swift         # Native iOS haptics engine
├── DesignSystem/
│   ├── AppTheme/
│   │   └── ThemeColors.swift            # Vibrant color palette & gradients
│   └── Components/
│       ├── StorageCardView.swift        # Top storage status card
│       ├── CategoryRowView.swift        # Section row items
│       ├── MediaThumbnailView.swift     # Async thumbnail with badges
│       └── EmptyStateView.swift         # Empty state placeholder
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift               # Gallery Cleaner dashboard
│   │   └── HomeViewModel.swift          # Reactive state & scan coordinator
│   ├── Explore/
│   │   ├── ExploreView.swift            # Year cards overview
│   │   ├── SwipeReviewView.swift        # Card-deck swipe cleaner
│   │   └── ReviewCompleteView.swift     # Review completion summary
│   ├── Trash/
│   │   └── TrashView.swift              # Trash staging, filters, and actions
│   ├── Screenshots/
│   │   └── ScreenshotsView.swift        # All screenshots grid & batch cleaner
│   ├── Videos/
│   │   └── VideosListView.swift         # All videos grid with durations & sizes
│   ├── DuplicatePhotos/
│   │   └── DuplicatePhotosView.swift    # Duplicate sets with 1-tap cleaner
│   ├── SimilarPhotos/
│   │   └── SimilarPhotosView.swift      # Similar shots with best-pick badge
│   ├── DuplicateVideos/
│   │   └── DuplicateVideosView.swift    # Duplicate video sets
│   └── LargeVideos/
│       └── LargeVideosView.swift        # Sorted biggest first with size pills
└── ContentView.swift                    # Root TabView (Home, Explore, Trash)
```

---

## 📲 How to Run

### In Xcode / Simulator
1. Open `GalleryCleanerApp.xcodeproj` in Xcode.
2. Select any iPhone simulator (e.g., iPhone 15 Pro, iPhone 16 Pro).
3. Press **Cmd + R** to run.
4. If testing on a blank simulator, the built-in mock gallery will automatically populate sample screenshots, duplicate groups, similar photos, and heavy videos.

### On Physical Device (for Screen Recording)
1. Connect your iPhone via USB.
2. In Xcode, select your connected iPhone as the run target.
3. Select the `GalleryCleanerApp` target, go to **Signing & Capabilities**, and select your Apple Developer Team / Personal Team.
4. Press **Cmd + R** to build and install.
5. On your iPhone: Grant **Photo Library** access when prompted.
6. Open **QuickTime Player** on your Mac > **File** > **New Movie Recording** > Select your iPhone as camera source to capture a high-definition real-device screen recording.

---

## 📋 AI Prompts Log (Google Sheets Submission)

As required for submission, the complete list of prompts and context given to the AI assistant is documented in:
- **`AI_PROMPTS_LOG.csv`**: Ready to import into Google Sheets (`File` > `Import` > `Upload`).
- **`AI_PROMPTS_LOG.md`**: Formatted table for direct GitHub viewing.
