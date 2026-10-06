import SwiftUI

@MainActor
public struct SwipeReviewView: View {
    let groupTitle: String
    let items: [MediaItem]
    @State private var currentIndex = 0
    @State private var cardOffset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss
    @StateObject private var trashManager = TrashManager.shared
    
    // Stats
    @State private var trashedCount = 0
    @State private var keptCount = 0
    @State private var savedBytes: Int64 = 0
    @State private var isCompleted = false
    
    // History
    @State private var history: [(item: MediaItem, wasTrashed: Bool)] = []
    
    public init(groupTitle: String = "", items: [MediaItem]) {
        self.groupTitle = groupTitle
        self.items = items
    }
    
    public var body: some View {
        ZStack {
            AppTheme.viewBackground
                .ignoresSafeArea()
            
            if isCompleted || items.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.accentTeal)
                    
                    Text("All Done!")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("You deleted \(trashedCount) items and saved \(ByteCountFormatter.string(fromByteCount: savedBytes, countStyle: .file)).")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: { dismiss() }) {
                        Text("Finish")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(AppTheme.primaryBlue)
                            .cornerRadius(26)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
            } else {
                VStack(spacing: 0) {
                    // Header Bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(Color.appCardBackground)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Review")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("\(currentIndex) of \(items.count)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: undoLastSwipe) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(history.isEmpty ? .secondary.opacity(0.3) : .primary)
                                .frame(width: 44, height: 44)
                                .background(Color.appCardBackground)
                                .clipShape(Circle())
                        }
                        .disabled(history.isEmpty)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Progress & Stats
                    VStack(spacing: 12) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.appCardBackground)
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(AppTheme.primaryBlue)
                                    .frame(
                                        width: items.isEmpty ? 0 : geo.size.width * CGFloat(currentIndex) / CGFloat(items.count),
                                        height: 6
                                    )
                                    .animation(.spring(), value: currentIndex)
                            }
                        }
                        .frame(height: 6)
                        
                        HStack {
                            Text("\(ByteCountFormatter.string(fromByteCount: savedBytes, countStyle: .file)) saved")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.accentTeal)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // Card Deck
                    ZStack {
                        ForEach(Array(items.enumerated().reversed()), id: \.element.id) { index, item in
                            if index >= currentIndex && index <= currentIndex + 2 {
                                let isTopCard = (index == currentIndex)
                                cardView(for: item, isTop: isTopCard)
                                    .offset(x: isTopCard ? cardOffset.width : 0, y: isTopCard ? cardOffset.height : CGFloat((index - currentIndex) * 8))
                                    .scaleEffect(isTopCard ? 1.0 : (1.0 - CGFloat(index - currentIndex) * 0.05))
                                    .rotationEffect(isTopCard ? .degrees(Double(cardOffset.width / 20)) : .zero)
                                    .gesture(
                                        isTopCard ? dragGesture(item: item) : nil
                                    )
                                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: cardOffset)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxHeight: .infinity)
                    .padding(.bottom, 40)
                    
                    // Bottom Buttons
                    HStack(spacing: 30) {
                        Button(action: {
                            if currentIndex < items.count {
                                swipeCard(item: items[currentIndex], toTrash: true)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.appCardBackground)
                                    .frame(width: 70, height: 70)
                                    .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppTheme.accentRed)
                            }
                        }
                        
                        Button(action: {
                            if currentIndex < items.count {
                                swipeCard(item: items[currentIndex], toTrash: false)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.appCardBackground)
                                    .frame(width: 70, height: 70)
                                    .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(AppTheme.accentGreen)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func cardView(for item: MediaItem, isTop: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.appCardBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 15, y: 8)
            
            MediaThumbnailView(
                item: item,
                isSelected: false,
                showSelectionBadge: false,
                showSizeBadge: false,
                cornerRadius: 30
            )
            .padding(8) // Adds a nice bezel around the image
            
            if isTop {
                VStack {
                    HStack {
                        if cardOffset.width > 20 {
                            Text("KEEP")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(AppTheme.accentGreen)
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.accentGreen, lineWidth: 4)
                                )
                                .rotationEffect(.degrees(-15))
                                .padding(.leading, 20)
                                .padding(.top, 40)
                                .opacity(Double(cardOffset.width / 100.0))
                        }
                        
                        Spacer()
                        
                        if cardOffset.width < -20 {
                            Text("TRASH")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(AppTheme.accentRed)
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.accentRed, lineWidth: 4)
                                )
                                .rotationEffect(.degrees(15))
                                .padding(.trailing, 20)
                                .padding(.top, 40)
                                .opacity(Double(abs(cardOffset.width) / 100.0))
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func dragGesture(item: MediaItem) -> some Gesture {
        DragGesture()
            .onChanged { value in
                cardOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                if value.translation.width < -threshold {
                    swipeCard(item: item, toTrash: true)
                } else if value.translation.width > threshold {
                    swipeCard(item: item, toTrash: false)
                } else {
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
