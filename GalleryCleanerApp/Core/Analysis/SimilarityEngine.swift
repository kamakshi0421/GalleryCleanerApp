import Foundation
import Photos
import Vision

public final class SimilarityEngine: Sendable {
    public static let shared = SimilarityEngine()
    
    private init() {}
    
    /// Finds photos that look nearly the same (e.g., burst shots, same scene)
    public func findSimilarPhotos(from items: [MediaItem]) async -> [SimilarGroup] {
        return await Task.detached(priority: .userInitiated) {
            let photoItems = items.filter { $0.isPhoto }
            guard photoItems.count > 1 else { return [] }
            
            // Sort items chronologically
            let sorted = photoItems.sorted { $0.creationDate < $1.creationDate }
            
            var clusters: [[MediaItem]] = []
            var currentCluster: [MediaItem] = [sorted[0]]
            
            for i in 1..<sorted.count {
                let prev = sorted[i - 1]
                let curr = sorted[i]
                
                let timeDelta = abs(curr.creationDate.timeIntervalSince(prev.creationDate))
                
                // If photos were taken within 90 seconds of each other with similar aspect ratio
                let prevAspect = Double(prev.pixelWidth) / Double(max(1, prev.pixelHeight))
                let currAspect = Double(curr.pixelWidth) / Double(max(1, curr.pixelHeight))
                let aspectDiff = abs(prevAspect - currAspect)
                
                // Similar mock titles or close temporal distance
                let isMockMatch = (prev.mockTitle != nil && curr.mockTitle != nil &&
                                  prev.mockTitle!.prefix(6) == curr.mockTitle!.prefix(6))
                
                if (timeDelta <= 90 && aspectDiff < 0.1) || (isMockMatch && timeDelta <= 300) {
                    currentCluster.append(curr)
                } else {
                    if currentCluster.count > 1 {
                        clusters.append(currentCluster)
                    }
                    currentCluster = [curr]
                }
            }
            
            if currentCluster.count > 1 {
                clusters.append(currentCluster)
            }
            
            var groups: [SimilarGroup] = []
            for cluster in clusters {
                // Best item is the one with highest resolution / size
                let best = cluster.max { $0.fileSize < $1.fileSize }
                groups.append(SimilarGroup(
                    similarityScore: 0.92,
                    items: cluster,
                    selectedKeepId: best?.id
                ))
            }
            
            return groups.sorted { $0.reclaimableSpace > $1.reclaimableSpace }
        }.value
    }
    
    /// Finds videos that have similar duration or are recorded around the same time
    public func findSimilarVideos(from items: [MediaItem]) async -> [SimilarGroup] {
        return await Task.detached(priority: .userInitiated) {
            let videoItems = items.filter { $0.isVideo }
            guard videoItems.count > 1 else { return [] }
            
            let sorted = videoItems.sorted { $0.creationDate < $1.creationDate }
            var clusters: [[MediaItem]] = []
            var currentCluster: [MediaItem] = [sorted[0]]
            
            for i in 1..<sorted.count {
                let prev = sorted[i - 1]
                let curr = sorted[i]
                
                let timeDelta = abs(curr.creationDate.timeIntervalSince(prev.creationDate))
                let durationDelta = abs(curr.duration - prev.duration)
                
                if (timeDelta <= 300 && durationDelta <= 3.0) || (durationDelta <= 1.0 && abs(prev.fileSize - curr.fileSize) < 5_000_000) {
                    currentCluster.append(curr)
                } else {
                    if currentCluster.count > 1 {
                        clusters.append(currentCluster)
                    }
                    currentCluster = [curr]
                }
            }
            
            if currentCluster.count > 1 {
                clusters.append(currentCluster)
            }
            
            var groups: [SimilarGroup] = []
            for cluster in clusters {
                let best = cluster.max { $0.fileSize < $1.fileSize }
                groups.append(SimilarGroup(
                    similarityScore: 0.88,
                    items: cluster,
                    selectedKeepId: best?.id
                ))
            }
            
            return groups.sorted { $0.reclaimableSpace > $1.reclaimableSpace }
        }.value
    }
}
