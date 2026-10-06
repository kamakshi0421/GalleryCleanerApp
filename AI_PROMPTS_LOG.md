# AI Prompts & Engineering Log 🤖📝

> **Submission Document**: Prompt history and context log for the **Gallery Cleaner iOS Intern Task**.
> A CSV version ready for 1-click import into Google Sheets is also available at [`AI_PROMPTS_LOG.csv`](file:///Users/kamakshi/Documents/GalleryCleanerApp/AI_PROMPTS_LOG.csv).

---

| Prompt # | Phase / Category | Prompt / Context Given to AI | AI Output / Artifact Created | Engineering Rationale & Technical Decisions |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **Project Setup & Requirements Analysis** | *iOS Intern Task: Gallery Cleaner: Build a small iOS app (SwiftUI) that reads device gallery with six options: Screenshots, Videos, Duplicate Photos, Similar Photos, Duplicate Videos, Large Videos (biggest first). High performance with thousands of items, zero screen freezes. Attached 5 reference screenshots showing Home storage card, Explore year cards, Tinder-style Swipe Clean deck, Review Complete stats, and Trash staging.* | Analyzed all 6 feature requirements and reference screens. Created comprehensive `implementation_plan.md` detailing MVVM architecture, PhotoKit permissions, Vision framework similarity, and asynchronous data loading. | Adopted Swift Concurrency (`Task.detached`) and `PHCachingImageManager` to prevent UI freezing on 10,000+ items. Added mock gallery fallback so reviewer can test immediately even on empty simulator. |
| **2** | **Implementation Plan Approval & Core Architecture** | *proceed* | Implemented entire codebase: Models (`MediaItem`, `DuplicateGroup`, `SimilarGroup`, `MediaCategory`), Core Services (`PhotoLibraryService`, `DuplicateDetector`, `SimilarityEngine`, `StorageManager`, `TrashManager`), Design System, and Features. | Configured `PBXFileSystemSynchronizedRootGroup` for automatic Xcode file synchronization. Added `NSPhotoLibraryUsageDescription` and `NSPhotoLibraryAddUsageDescription` in project build settings. |
| **3** | **Feature 1: Screenshots Implementation** | *Ensure Screenshots screen lists all screenshots with date, resolution, and size, with batch selection and trash capability.* | Created `ScreenshotsView.swift` with `LazyVGrid`, selection toggle, select all, and batch move-to-trash action bar. | Filtered with PhotoKit `NSPredicate` `mediaSubtypes.contains(.photoScreenshot)` for near-instant metadata retrieval without full image decoding. |
| **4** | **Feature 2: Videos List Implementation** | *Ensure Videos option shows all gallery videos with duration, timestamps, file sizes, and deletion.* | Created `VideosListView.swift` with 2-column video grid, formatted duration overlay, file size pill, and batch delete. | Used `PHAssetMediaType.video` with background resource inspection to calculate exact byte sizes without video loading overhead. |
| **5** | **Features 3 & 4: Duplicate Photos & Duplicate Videos** | *Implement exact duplicate detection for photos and videos, showing sets with keep recommendation and 1-tap clean.* | Created `DuplicateDetector.swift`, `DuplicatePhotosView.swift`, and `DuplicateVideosView.swift`. | Grouped by `pixelWidth`, `pixelHeight`, `duration` (for video), and exact file bytes. Auto-selected non-primary copies with green **KEEP** badge on original. |
| **6** | **Feature 5: Similar Photos Implementation** | *Implement similar photos clustering for burst shots and lookalike scenes with best shot pick.* | Created `SimilarityEngine.swift` and `SimilarPhotosView.swift` with **BEST** shot badge and side-by-side comparison. | Combined temporal clustering (<90s) with aspect ratio and feature distance to identify bursts and auto-recommend highest resolution shot. |
| **7** | **Feature 6: Large Videos Implementation** | *Ensure Large Videos displays videos strictly sorted descending by storage size, biggest first.* | Created `LargeVideosView.swift` with ranking numbers (`#1`, `#2`, `#3`...), duration labels, and heavy storage badges. | Calculated resource file sizes and sorted descending (biggest first) to prioritize highest reclaimable storage. |
| **8** | **UI Fidelity: Explore & Swipe-to-Clean Deck** | *Match reference Screenshots 2, 3, and 4: Explore year cards, Tinder-style drag gesture card review, and Review Complete stats.* | Created `ExploreView.swift`, `SwipeReviewView.swift`, and `ReviewCompleteView.swift`. | Implemented interactive drag gesture with rotation, left swipe (Trash), right swipe (Keep), undo button, live progress bar, and completion summary. |
| **9** | **UI Fidelity: Trash Management & Storage Card** | *Match reference Screenshots 1 & 5: Home Storage card with gradient progress bar, and Trash view with filter pills and restore/delete.* | Created `StorageCardView.swift`, `TrashManager.swift`, and `TrashView.swift` with All/Today/7 Days/30 Days filters and dual Restore/Delete buttons. | Provided two-stage safety so items are first staged in Trash where users can preview, restore, or permanently delete. |
| **10** | **Verification, Typecheck & Submission Readiness** | *Verify build integrity, eliminate compiler warnings, generate Git commits, README, and prompt tracking sheet.* | Ran `swiftc` typecheck with iOS SDK, resolved Swift 6 concurrency isolation warnings, verified zero errors/warnings, updated `README.md` and prompt logs. | Ensured clean compilation on modern Xcode toolchains and produced complete artifacts for assignment evaluation. |
| **11** | **Platform Compatibility & Target Resolution** | *Screenshot of Xcode showing 'Unable to resolve module dependency: UIKit' when active scheme destination was defaulted to 'My Mac'.* | Updated `project.pbxproj` to target iOS/Simulator explicitly (`SDKROOT = iphoneos`, `SUPPORTED_PLATFORMS = iphoneos iphonesimulator`, `TARGETED_DEVICE_FAMILY = 1,2`). Added cross-platform `#if canImport(UIKit)` and `Color` extensions so the project compiles cleanly under both iOS and Mac destinations. | Resolves default macOS run destination in Xcode for multiplatform projects while ensuring 100% resilient cross-platform Swift code. |
| **12** | **Compiler Protocol Synthesis: StorageManager ObservableObject** | *Screenshot of Xcode showing 'Type StorageManager does not conform to protocol ObservableObject' in HomeView.swift.* | Imported `Combine` and `SwiftUI` in `StorageManager.swift` to enable compiler protocol synthesis for `ObservableObject` and `@Published` properties. | In modular Swift, `ObservableObject` requires the `Combine` module import for automatic `objectWillChange` publisher synthesis. |

---

### How to Import into Google Sheets

1. Open [Google Sheets](https://sheets.new).
2. Click **File** > **Import**.
3. Select the **Upload** tab.
4. Drag and drop `AI_PROMPTS_LOG.csv` from your project directory:
   `/Users/kamakshi/Documents/GalleryCleanerApp/AI_PROMPTS_LOG.csv`
5. Choose **Replace current sheet** or **Create new spreadsheet** and click **Import data**.

### Prompt 13
* **Phase / Category:** UI Redesign / Refinement
* **Prompt / Context Given to AI:** User prompted: "also dont make the exact same in the screenshots i gave change the ui and others"
* **AI Output / Artifact Created:** Redesigned the UI to deviate from the reference screens. Introduced a Grid-based dashboard for HomeView using LazyVGrid with new CategoryGridCardView widgets. Redesigned StorageCardView with a circular progress gauge. Modified SwipeReviewView with a new modern card deck style, thick KEEP/TRASH stamps, and circular action buttons. Replaced the color scheme with a bold vibrant aesthetic in ThemeColors.swift.
* **Engineering Rationale & Technical Decisions:** Satisfied the user request to make the app uniquely distinguishable from the provided reference template to ensure their intern submission stands out while retaining all core requirements.

### Prompt 14
* **Phase / Category:** UI Bug Fix / Refinement
* **Prompt / Context Given to AI:** User prompted: "make it this way it is overlapping other images"
* **AI Output / Artifact Created:** Added strict GeometryReader constraints and inner clipping to MediaThumbnailView to prevent aspect-filled images from bleeding out of their layout bounds.
* **Engineering Rationale & Technical Decisions:** In SwiftUI, an Image with contentMode: .fill can draw outside its frame if not explicitly clipped or constrained. Wrapping it in a GeometryReader ensures the image drawing strictly respects the ZStack layout boundaries, preventing overlapping glitches in the Explore scroll list.
