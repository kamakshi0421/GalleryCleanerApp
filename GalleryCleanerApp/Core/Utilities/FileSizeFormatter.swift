import Foundation

public enum FileSizeFormatter {
    private static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter
    }()
    
    public static func string(from bytes: Int64) -> String {
        return byteFormatter.string(fromByteCount: bytes)
    }
    
    public static func gigabytes(from bytes: Int64) -> Double {
        return Double(bytes) / 1_073_741_824.0
    }
}
