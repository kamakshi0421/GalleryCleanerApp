import Foundation

public enum DateFilterOption: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case today = "Today"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    
    public var id: String { rawValue }
    
    public func matches(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return true
        case .today:
            return calendar.isDateInToday(date)
        case .last7Days:
            guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return true }
            return date >= sevenDaysAgo
        case .last30Days:
            guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) else { return true }
            return date >= thirtyDaysAgo
        }
    }
}
