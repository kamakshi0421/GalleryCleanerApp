import Foundation

public enum AnalysisState: Equatable, Sendable {
    case idle
    case scanning(progress: Double, stage: String)
    case completed
    case error(message: String)
    
    public var isScanning: Bool {
        if case .scanning = self { return true }
        return false
    }
    
    public var stageTitle: String {
        switch self {
        case .idle: return "Ready"
        case .scanning(_, let stage): return stage
        case .completed: return "Scan Complete"
        case .error(let msg): return "Error: \(msg)"
        }
    }
    
    public var progressValue: Double {
        switch self {
        case .scanning(let progress, _): return progress
        case .completed: return 1.0
        default: return 0.0
        }
    }
}
