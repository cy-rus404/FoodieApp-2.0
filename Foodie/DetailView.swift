import SwiftUI

struct DetailView: View {
    let item: FoodItem

    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var quantity = 1
    @State private var appeared = false
    @State private var added = false

    private var total: Double { item.price * Double(quantity) }

    private var details: String {
        switch item.category {
        case .burgers: return "Juicy, flame-grilled and stacked fresh to order. Served hot with our house sauce."
        case .pizza: return "Hand-stretched dough, baked in a stone oven until the crust is crisp and golden."
        case .asian: return "Prepared fresh by our chefs with authentic ingredients and a balanced, light finish."
        case .african: return "A slow-cooked favourite, full of rich flavour and made the way it's meant to be."
        case .salads: return "Crisp, colourful and made from fresh produce. Light, filling and full of goodness."
        case .desserts: return "A sweet finish, made in small batches and served fresh."
        case .drinks: return "Cold, refreshing and blended to order. Best enjoyed straight away."
        case .all: return "Freshly made and delivered hot."
        }
    }

    private var ingredients: [String] {
        switch item.category {
        case .burgers: return ["Beef patty", "Cheddar", "Pickles", "Brioche bun", "House sauce"]
        case .pizza: return ["Stone-baked dough", "Tomato sauce", "Mozzarella", "Fresh basil"]
        case .asian: return ["Fresh rice", "Seaweed", "Soy glaze", "Sesame"]
        case .african: return ["Spiced rice", "Tomato base", "Peppers", "Slow-cooked protein"]
        case .salads: return ["Fresh greens", "Cherry tomato", "Light dressing", "Toasted seeds"]
        case .desserts: return ["Real chocolate", "Butter", "Cream", "Vanilla"]
        case .drinks: return ["Fresh fruit", "Ice", "Natural sweetener"]
        case .all: return []
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.paper.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    hero
                    info
                }
                .padding(.bottom, 130)
            }

            bottomBar
        }
        .onAppear { appeared = true }
    }

    private var hero: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: item.tint).opacity(0.3), Color.paper],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            Circle()
                .fill(Color(hex: item.tint).opacity(0.18))
                .frame(width: 250, height: 250)
                .scaleEffect(appeared ? 1 : 0.5)
                .animation(.spring(response: 0.7, dampingFraction: 0.7), value: appeared)

            FloatingEmoji(emoji: item.emoji, size: 140)
                .shadow(color: .black.opacity(0.2), radius: 14, y: 14)
                .scaleEffect(appeared ? 1 : 0.4)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1), value: appeared)

            VStack {
                HStack {
                    roundButton("chevron.left", label: "Back") { dismiss() }
                    Spacer()
                    heartButton
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .frame(height: 320)
    }

    private func roundButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textMain)
                .frame(width: 44, height: 44)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(label)
    }

    private var heartButton: some View {
        let favorite = store.isFavorite(item)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                store.toggleFavorite(item)
            }
        } label: {
            Image(systemName: favorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(favorite ? .coral : .textMain)
                .frame(width: 44, height: 44)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                .scaleEffect(favorite ? 1.1 : 1)
        }
        .accessibilityLabel(favorite ? "Remove from favourites" : "Add to favourites")
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.textMain)
                    Spacer()
                    Text(item.priceText)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.coral)
                }
                Text(item.restaurant)
                    .font(.subheadline)
                    .foregroundColor(.muted)
            }
            .staggerIn(1, show: appeared)

            HStack(spacing: 10) {
                statPill("star.fill", String(format: "%.1f", item.rating), tint: .amber)
                statPill("clock", "\(item.minutes) min", tint: .coral)
                statPill("flame", "\(item.kcal) kcal", tint: Color(hex: 0xE0892B))
            }
            .staggerIn(2, show: appeared)

            Text(details)
                .font(.subheadline)
                .foregroundColor(.muted)
                .lineSpacing(5)
                .staggerIn(3, show: appeared)

            VStack(alignment: .leading, spacing: 12) {
                Text("What's inside")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.textMain)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ingredients, id: \.self) { name in
                            Text(name)
                                .font(.footnote.weight(.medium))
                                .foregroundColor(.textMain)
                                .padding(.horizontal, 14)
                                .frame(height: 36)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.stroke, lineWidth: 1))
                        }
                    }
                }
            }
            .staggerIn(4, show: appeared)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func statPill(_ symbol: String, _ text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(tint)
            Text(text)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.textMain)
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var bottomBar: some View {
        HStack(spacing: 14) {
            HStack(spacing: 4) {
                stepButton("minus", label: "Decrease") {
                    if quantity > 1 { quantity -= 1 }
                }
                Text("\(quantity)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.textMain)
                    .frame(width: 28)
                stepButton("plus", label: "Increase") {
                    if quantity < 20 { quantity += 1 }
                }
            }
            .padding(6)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.stroke, lineWidth: 1))

            Button(action: addToCart) {
                HStack(spacing: 8) {
                    if added {
                        Image(systemName: "checkmark")
                        Text("Added")
                    } else {
                        Text("Add to cart")
                        Text("·")
                        Text(money(total))
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(added ? Color(hex: 0x2E8B57) : Color.coral)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .animation(.easeInOut(duration: 0.25), value: added)
            }
            .buttonStyle(PressStyle())
            .disabled(added)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background(
            Color.paper
                .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func stepButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textMain)
                .frame(width: 40, height: 40)
                .background(Color.paper)
                .clipShape(Circle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(label)
    }

    private func addToCart() {
        store.add(item, quantity: quantity)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        added = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            dismiss()
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(item: MenuData.items[0])
            .environmentObject(AppStore())
            .preferredColorScheme(.light)
            .previewDevice("iPhone 14")
    }
}
