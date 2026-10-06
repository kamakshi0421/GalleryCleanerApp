import SwiftUI

@MainActor
public struct StorageCardView: View {
    @ObservedObject var storageManager: StorageManager
    
    public init(storageManager: StorageManager? = nil) {
        self.storageManager = storageManager ?? .shared
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Device Storage")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(storageManager.formattedUsedGB) / \(storageManager.formattedTotalGB) Used")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(AppTheme.primaryBlue.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(storageManager.usedPercentage))
                        .stroke(AppTheme.storageGradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: storageManager.usedPercentage)
                    
                    Text(storageManager.percentString)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle().fill(AppTheme.accentPink).frame(width: 8, height: 8)
                        Text("Used")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    Text(storageManager.formattedUsedGB)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle().fill(AppTheme.accentTeal).frame(width: 8, height: 8)
                        Text("Free")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    Text(storageManager.formattedFreeGB)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appCardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}
