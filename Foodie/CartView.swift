import SwiftUI

struct CartView: View {
    var onFinish: () -> Void = {}

    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var codeInvalid = false
    @State private var shake: CGFloat = 0
    @State private var showCheckout = false
    @State private var appeared = false
    @FocusState private var codeFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.paper
                .ignoresSafeArea()
                .onTapGesture { codeFocused = false }

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    .staggerIn(0, show: appeared)

                if store.lines.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(store.lines, id: \.0.id) { line in
                                row(line.0, line.1)
                                    .transition(
                                        .asymmetric(
                                            insertion: .opacity,
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        )
                                    )
                            }
                            .staggerIn(1, show: appeared)

                            promoSection.staggerIn(2, show: appeared)
                            summary.staggerIn(3, show: appeared)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 130)
                    }
                }
            }

            if !store.lines.isEmpty {
                checkoutBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear { appeared = true }
        .fullScreenCover(isPresented: $showCheckout) {
            CheckoutView(onFinish: {
                showCheckout = false
                onFinish()
            })
            .environmentObject(store)
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textMain)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel("Back")

            Text("My cart")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.textMain)
                .padding(.leading, 6)

            Spacer()

            if !store.lines.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        store.clear()
                    }
                } label: {
                    Text("Clear")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.coral)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            FloatingEmoji(emoji: "🛒", size: 80)
            Text("Your cart is empty")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.textMain)
            Text("Add something tasty and it will show up here")
                .font(.subheadline)
                .foregroundColor(.muted)
                .multilineTextAlignment(.center)
            Button { dismiss() } label: {
                Text("Browse food")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .frame(height: 52)
                    .background(Color.coral)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressStyle())
            .padding(.top, 8)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity)
    }

    private func row(_ item: FoodItem, _ quantity: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: item.tint).opacity(0.14))
                Text(item.emoji)
                    .font(.system(size: 34))
            }
            .frame(width: 68, height: 68)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textMain)
                    .lineLimit(1)
                Text(item.restaurant)
                    .font(.caption)
                    .foregroundColor(.muted)
                    .lineLimit(1)
                Text(money(item.price * Double(quantity)))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.coral)
            }

            Spacer(minLength: 4)

            HStack(spacing: 2) {
                stepButton(quantity == 1 ? "trash" : "minus", label: "Remove one \(item.name)") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        store.remove(item)
                    }
                }
                Text("\(quantity)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.textMain)
                    .frame(width: 24)
                stepButton("plus", label: "Add one \(item.name)") {
                    store.add(item)
                }
            }
            .padding(4)
            .background(Color.paper)
            .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func stepButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(symbol == "trash" ? .coral : .textMain)
                .frame(width: 30, height: 30)
                .background(Color.white)
                .clipShape(Circle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(label)
    }

    private var promoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let applied = store.appliedCode {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(hex: 0x2E8B57))
                    Text("\(applied) applied")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textMain)
                    Spacer()
                    Button("Remove") {
                        withAnimation(.easeOut(duration: 0.25)) {
                            store.removePromo()
                        }
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.coral)
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color(hex: 0x2E8B57).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .transition(.opacity)
            } else {
                HStack(spacing: 10) {
                    AppField(
                        icon: "tag",
                        placeholder: "Promo code",
                        text: $code,
                        highlighted: codeFocused
                    )
                    .focused($codeFocused)
                    .submitLabel(.done)
                    .onSubmit { applyCode() }
                    .modifier(Shake(shakes: shake))

                    Button(action: applyCode) {
                        Text("Apply")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .frame(height: 56)
                            .background(Color.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(PressStyle())
                }

                Text(codeInvalid ? "That code isn't valid" : "Try FOODIE or SAVE10")
                    .font(.caption)
                    .foregroundColor(codeInvalid ? Color(hex: 0xE5484D) : .muted)
                    .padding(.leading, 4)
            }
        }
        .onChange(of: code) { _ in codeInvalid = false }
        .animation(.easeOut(duration: 0.25), value: store.appliedCode)
    }

    private var summary: some View {
        VStack(spacing: 12) {
            summaryRow("Subtotal", money(store.total))

            if store.discount > 0 {
                summaryRow("Discount", "-" + money(store.discount), tint: Color(hex: 0x2E8B57))
            }

            summaryRow(
                "Delivery",
                store.deliveryFee == 0 ? "Free" : money(store.deliveryFee),
                tint: store.deliveryFee == 0 ? Color(hex: 0x2E8B57) : nil
            )

            Rectangle()
                .fill(Color.stroke)
                .frame(height: 1)

            HStack {
                Text("Total")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.textMain)
                Spacer()
                Text(money(store.grandTotal))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.textMain)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .animation(.easeOut(duration: 0.25), value: store.grandTotal)
    }

    private func summaryRow(_ title: String, _ value: String, tint: Color? = nil) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.muted)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(tint ?? .textMain)
        }
    }

    private var checkoutBar: some View {
        Button {
            codeFocused = false
            showCheckout = true
        } label: {
            HStack {
                Text("Go to checkout")
                Spacer()
                Text(money(store.grandTotal))
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .frame(height: 58)
            .background(Color.coral)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.coral.opacity(0.35), radius: 14, y: 6)
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .padding(.top, 12)
        .background(
            Color.paper
                .shadow(color: .black.opacity(0.05), radius: 12, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func applyCode() {
        codeFocused = false
        if store.applyPromo(code) {
            code = ""
            codeInvalid = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            codeInvalid = true
            withAnimation(.default) { shake += 1 }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static func makeStore() -> AppStore {
        let store = AppStore()
        store.add(MenuData.items[0], quantity: 2)
        store.add(MenuData.items[4])
        store.add(MenuData.items[10])
        return store
    }

    static var previews: some View {
        CartView()
            .environmentObject(makeStore())
            .preferredColorScheme(.light)
            .previewDevice("iPhone 14")
    }
}
