import SwiftUI

public struct SwipeReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var trashManager: TrashManager = .shared
    
    public let groupTitle: String
    public let items: [MediaItem]
    
    @State private var currentIndex: Int = 0
    @State private var cardOffset: CGSize = .zero
    @State private var history: [(item: MediaItem, wasTrashed: Bool)] = []
    @State private var keptCount: Int = 0
    @State private var trashedCount: Int = 0
    @State private var savedBytes: Int64 = 0
    @State private var isCompleted: Bool = false
    
    public init(groupTitle: String, items: [MediaItem]) {
        self.groupTitle = groupTitle
        self.items = items
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isCompleted {
                ReviewCompleteView(
                    groupTitle: groupTitle,
                    keptCount: keptCount,
                    trashedCount: trashedCount,
                    reclaimableBytes: savedBytes,
                    onDone: {
                        dismiss()
                    }
                )
            } else {
                VStack(spacing: 16) {
                    // Top Navigation Bar (Matches Screenshot 3)
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Button(action: undoLastSwipe) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(history.isEmpty ? .gray : .white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                        .disabled(history.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Progress Bar & Info (Matches Screenshot 3)
                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(Color.white)
                                    .frame(
                                        width: items.isEmpty ? 0 : geo.size.width * CGFloat(currentIndex) / CGFloat(items.count),
                                        height: 4
                                    )
                                    .animation(.spring(), value: currentIndex)
                            }
                        }
                        .frame(height: 4)
                        
                        HStack {
                            Text("Swiped \(currentIndex) / \(items.count) elements")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text("Saved \(ByteCountFormatter.string(fromByteCount: savedBytes, countStyle: .file))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Card Deck
                    ZStack {
                        // Background cards stack
                        ForEach(Array(items.enumerated().reversed()), id: \.element.id) { index, item in
                            if index >= currentIndex && index <= currentIndex + 2 {
                                let isTopCard = (index == currentIndex)
                                cardView(for: item, isTop: isTopCard)
                                    .offset(x: isTopCard ? cardOffset.width : 0, y: isTopCard ? cardOffset.height : CGFloat((index - currentIndex) * 6))
                                    .scaleEffect(isTopCard ? 1.0 : (1.0 - CGFloat(index - currentIndex) * 0.04))
                                    .rotationEffect(isTopCard ? .degrees(Double(cardOffset.width / 15)) : .zero)
                                    .gesture(
                                        isTopCard ? dragGesture(item: item) : nil
                                    )
                                    .animation(.spring(response: 0.45, dampingFraction: 0.75), value: cardOffset)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxHeight: 520)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func cardView(for item: MediaItem, isTop: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.12))
            
            MediaThumbnailView(
                item: item,
                isSelected: false,
                showSelectionBadge: false,
                showSizeBadge: false,
                cornerRadius: 24
            )
            
            // Swipe Indicator Badges (Matches Screenshot 3)
            if isTop {
                VStack {
                    HStack(spacing: 24) {
                        // Trash Indicator (Swipe Left)
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(cardOffset.width < -30 ? 0.9 : 0.2))
                                .frame(width: 48, height: 48)
                            Image(systemName: "trash.fill")
                                .font(.system(size: 22))
                                .foregroundColor(cardOffset.width < -30 ? .white : .red)
                        }
                        .scaleEffect(cardOffset.width < -30 ? 1.15 : 1.0)
                        
                        // Keep / Heart Indicator (Swipe Right)
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.12, green: 0.78, blue: 0.65).opacity(cardOffset.width > 30 ? 0.9 : 0.2))
                                .frame(width: 48, height: 48)
                            Image(systemName: "heart.fill")
                                .font(.system(size: 22))
                                .foregroundColor(cardOffset.width > 30 ? .white : Color(red: 0.12, green: 0.78, blue: 0.65))
                        }
                        .scaleEffect(cardOffset.width > 30 ? 1.15 : 1.0)
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                }
            }
        }
        .shadow(color: Color.black.opacity(0.35), radius: 12, y: 6)
    }
    
    private func dragGesture(item: MediaItem) -> some Gesture {
        DragGesture()
            .onChanged { value in
                cardOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                if value.translation.width < -threshold {
                    // Swiped Left -> Trash
                    swipeCard(item: item, toTrash: true)
                } else if value.translation.width > threshold {
                    // Swiped Right -> Keep
                    swipeCard(item: item, toTrash: false)
                } else {
                    // Snap back
                    cardOffset = .zero
                }
            }
    }
    
    private func swipeCard(item: MediaItem, toTrash: Bool) {
        if toTrash {
            trashManager.moveToTrash(items: [item])
            trashedCount += 1
            savedBytes += item.fileSize
            HapticFeedback.heavy()
        } else {
            keptCount += 1
            HapticFeedback.light()
        }
        
        history.append((item: item, wasTrashed: toTrash))
        cardOffset = .zero
        currentIndex += 1
        
        if currentIndex >= items.count {
            isCompleted = true
            HapticFeedback.success()
        }
    }
    
    private func undoLastSwipe() {
        guard let last = history.popLast() else { return }
        
        if last.wasTrashed {
            trashManager.items.removeAll { $0.id == last.item.id }
            trashedCount = max(0, trashedCount - 1)
            savedBytes = max(0, savedBytes - last.item.fileSize)
        } else {
            keptCount = max(0, keptCount - 1)
        }
        
        currentIndex = max(0, currentIndex - 1)
        isCompleted = false
        HapticFeedback.selection()
    }
}
