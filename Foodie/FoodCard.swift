import SwiftUI

struct FloatingEmoji: View {
    let emoji: String
    let size: CGFloat
    @State private var up = false

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .offset(y: up ? -8 : 0)
            .rotationEffect(.degrees(up ? 4 : -4))
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    up = true
                }
            }
    }
}

struct FoodCard: View {
    let item: FoodItem
    @EnvironmentObject var store: AppStore
    @State private var bump = false

    private var quantity: Int { store.quantity(of: item) }
    private var favorite: Bool { store.isFavorite(item) }
    private var tint: Color { Color(hex: item.tint) }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.22))
                    .frame(width: 130, height: 130)
                    .offset(x: 52, y: -38)

                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 70, height: 70)
                    .offset(x: -62, y: 44)

                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 98, height: 98)
                        .shadow(color: tint.opacity(0.4), radius: 14, y: 10)
                    Circle()
                        .stroke(tint.opacity(0.25), lineWidth: 1)
                        .frame(width: 80, height: 80)
                    Text(item.emoji)
                        .font(.system(size: 52))
                        .rotationEffect(.degrees(-8))
                }

                VStack {
                    HStack {
                        ratingBadge
                        Spacer()
                        heartButton
                    }
                    Spacer()
                }
                .padding(10)
            }
            .frame(height: 132)
            .clipped()

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(.textMain)
                    .lineLimit(1)
                Text("\(item.restaurant) · \(item.minutes) min")
                    .font(.caption)
                    .foregroundColor(.muted)
                    .lineLimit(1)

                HStack {
                    Text(item.priceText)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.textMain)
                    Spacer()
                    addButton
                }
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(tint.opacity(0.2), lineWidth: 1)
        )
    }

    private var ratingBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundColor(.amber)
            Text(String(format: "%.1f", item.rating))
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.textMain)
        }
        .padding(.horizontal, 8)
        .frame(height: 24)
        .background(Color.white)
        .clipShape(Capsule())
    }

    private var heartButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                store.toggleFavorite(item)
            }
        } label: {
            Image(systemName: favorite ? "heart.fill" : "heart")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(favorite ? .coral : .muted)
                .frame(width: 28, height: 28)
                .background(Color.white)
                .clipShape(Circle())
                .scaleEffect(favorite ? 1.15 : 1)
        }
        .accessibilityLabel(favorite ? "Remove from favourites" : "Add to favourites")
    }

    private var addButton: some View {
        Button {
            store.add(item)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            bump = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                bump = false
            }
        } label: {
            Group {
                if quantity > 0 {
                    Text("\(quantity)")
                } else {
                    Image(systemName: "plus")
                }
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(Color.ink)
            .clipShape(Circle())
            .scaleEffect(bump ? 1.25 : 1)
        }
        .buttonStyle(PressStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: bump)
        .accessibilityLabel("Add \(item.name)")
    }
}
