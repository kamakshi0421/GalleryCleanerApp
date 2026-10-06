import SwiftUI

public struct ReviewCompleteView: View {
    public let groupTitle: String
    public let keptCount: Int
    public let trashedCount: Int
    public let reclaimableBytes: Int64
    public let onDone: () -> Void
    
    public init(
        groupTitle: String,
        keptCount: Int,
        trashedCount: Int,
        reclaimableBytes: Int64,
        onDone: @escaping () -> Void
    ) {
        self.groupTitle = groupTitle
        self.keptCount = keptCount
        self.trashedCount = trashedCount
        self.reclaimableBytes = reclaimableBytes
        self.onDone = onDone
    }
    
    public var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Large Green Checkmark (Matches Screenshot 4)
            ZStack {
                Circle()
                    .fill(Color(red: 0.18, green: 0.80, blue: 0.44))
                    .frame(width: 88, height: 88)
                    .shadow(color: Color(red: 0.18, green: 0.80, blue: 0.44).opacity(0.35), radius: 12, y: 6)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            
            // Header Text
            VStack(spacing: 8) {
                Text("Review Complete")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("All photos in \(groupTitle) have been reviewed.")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            
            // Stats Card (Matches Screenshot 4 dark card)
            VStack(spacing: 16) {
                statRow(
                    icon: "checkmark.circle.fill",
                    iconColor: Color(red: 0.18, green: 0.80, blue: 0.44),
                    title: "Photos Kept",
                    value: "\(keptCount)",
                    valueColor: .white
                )
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                statRow(
                    icon: "trash.circle.fill",
                    iconColor: Color(red: 0.95, green: 0.25, blue: 0.35),
                    title: "Moved to Trash",
                    value: "\(trashedCount)",
                    valueColor: .white
                )
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                statRow(
                    icon: "internaldrive.fill",
                    iconColor: Color(red: 0.20, green: 0.60, blue: 0.95),
                    title: "Reclaimable Space",
                    value: ByteCountFormatter.string(fromByteCount: reclaimableBytes, countStyle: .file),
                    valueColor: Color(red: 0.20, green: 0.60, blue: 0.95)
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(white: 0.16))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: 4)
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Done Button (Matches Screenshot 4 blue pill button)
            Button(action: onDone) {
                Text("Done")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.05, green: 0.50, blue: 0.98))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.blue.opacity(0.4), radius: 8, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
    
    private func statRow(icon: String, iconColor: Color, title: String, value: String, valueColor: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(iconColor)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(valueColor)
        }
    }
}
