import SwiftUI

@MainActor
public struct StorageCardView: View {
    @ObservedObject var storageManager: StorageManager
    
    public init(storageManager: StorageManager? = nil) {
        self.storageManager = storageManager ?? .shared
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header Row
            HStack(spacing: 12) {
                // Storage Device Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "iphone")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("iPhone Storage")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(storageManager.formattedUsedGB) of \(storageManager.formattedTotalGB) used")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Percentage Badge
                Text(storageManager.percentString)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.12))
                    )
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.95, green: 0.25, blue: 0.65),
                                    Color(red: 0.25, green: 0.55, blue: 0.98)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(8, geometry.size.width * CGFloat(storageManager.usedPercentage)),
                            height: 8
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: storageManager.usedPercentage)
                }
            }
            .frame(height: 8)
            
            // Legend Row
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.25, blue: 0.65))
                        .frame(width: 8, height: 8)
                    Text("Used: \(storageManager.formattedUsedGB)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.18, green: 0.80, blue: 0.44))
                        .frame(width: 8, height: 8)
                    Text("Free: \(storageManager.formattedFreeGB)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }
}
