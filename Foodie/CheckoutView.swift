import SwiftUI

enum PayMethod: String, CaseIterable, Identifiable {
    case card, momo, cash

    var id: String { rawValue }

    var title: String {
        switch self {
        case .card: return "Visa ending 4821"
        case .momo: return "Mobile money"
        case .cash: return "Cash on delivery"
        }
    }

    var subtitle: String {
        switch self {
        case .card: return "Default card"
        case .momo: return "MTN, Telecel or AirtelTigo"
        case .cash: return "Pay the courier"
        }
    }

    var symbol: String {
        switch self {
        case .card: return "creditcard.fill"
        case .momo: return "iphone"
        case .cash: return "banknote.fill"
        }
    }
}

struct CheckoutView: View {
    var onFinish: () -> Void = {}

    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var address = 0
    @State private var priority = false
    @State private var payment: PayMethod = .card
    @State private var loading = false
    @State private var placed = false
    @State private var appeared = false
    @State private var orderNumber = "FD-\(Int.random(in: 1000...9999))"

    private let addresses: [(name: String, line: String, symbol: String)] = [
        ("Home", "14 Oxford St, Osu, Accra", "house.fill"),
        ("Work", "Airport City, Accra", "briefcase.fill")
    ]

    private let green = Color(hex: 0x2E8B57)

    private var priorityFee: Double { priority ? 1.50 : 0 }
    private var finalTotal: Double { store.grandTotal + priorityFee }
    private var minutes: Int { priority ? 18 : 28 }

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()

            if placed {
                TrackingView(
                    total: finalTotal,
                    minutes: minutes,
                    orderNumber: orderNumber,
                    addressName: addresses[address].name,
                    onDone: {
                        store.clear()
                        onFinish()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                content
                    .transition(.opacity)
            }
        }
        .onAppear { appeared = true }
    }

    private var content: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    .staggerIn(0, show: appeared)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        addressSection.staggerIn(1, show: appeared)
                        speedSection.staggerIn(2, show: appeared)
                        paymentSection.staggerIn(3, show: appeared)
                        summarySection.staggerIn(4, show: appeared)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 130)
                }
            }

            placeBar
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
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.stroke, lineWidth: 1))
            }
            .buttonStyle(PressStyle())
            .disabled(loading)
            .accessibilityLabel("Back")

            Text("Checkout")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(.textMain)
                .padding(.leading, 6)

            Spacer()
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 19, weight: .bold, design: .serif))
            .foregroundColor(.textMain)
    }

    private func choiceCard<Content: View>(
        isOn: Bool,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Button(action: action) {
            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(isOn ? Color.coral : Color.stroke, lineWidth: isOn ? 2 : 1)
                )
        }
        .buttonStyle(PressStyle())
    }

    private func radio(_ isOn: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(isOn ? Color.coral : Color.stroke, lineWidth: 2)
                .frame(width: 24, height: 24)
            if isOn {
                Circle()
                    .fill(Color.coral)
                    .frame(width: 14, height: 14)
                    .transition(.scale)
            }
        }
    }

    private func iconTile(_ symbol: String, on: Bool) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(on ? .white : .textMain)
            .frame(width: 44, height: 44)
            .background(on ? Color.coral : Color.paper)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Deliver to")
            ForEach(0..<addresses.count, id: \.self) { i in
                let option = addresses[i]
                choiceCard(isOn: address == i) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        address = i
                    }
                } content: {
                    HStack(spacing: 14) {
                        iconTile(option.symbol, on: address == i)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(option.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textMain)
                            Text(option.line)
                                .font(.caption)
                                .foregroundColor(.muted)
                        }
                        Spacer()
                        radio(address == i)
                    }
                }
            }
        }
    }

    private var speedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Delivery speed")
            HStack(spacing: 12) {
                speedCard(title: "Standard", detail: "25–30 min", price: "Included", on: !priority) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { priority = false }
                }
                speedCard(title: "Priority", detail: "15–20 min", price: "+" + money(1.50), on: priority) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { priority = true }
                }
            }
        }
    }

    private func speedCard(
        title: String,
        detail: String,
        price: String,
        on: Bool,
        action: @escaping () -> Void
    ) -> some View {
        choiceCard(isOn: on, action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: title == "Priority" ? "bolt.fill" : "clock.fill")
                        .foregroundColor(on ? .coral : .muted)
                    Spacer()
                    radio(on)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textMain)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.muted)
                Text(price)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(title == "Priority" ? .coral : green)
            }
        }
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Payment")
            ForEach(PayMethod.allCases) { method in
                choiceCard(isOn: payment == method) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        payment = method
                    }
                } content: {
                    HStack(spacing: 14) {
                        iconTile(method.symbol, on: payment == method)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(method.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.textMain)
                            Text(method.subtitle)
                                .font(.caption)
                                .foregroundColor(.muted)
                        }
                        Spacer()
                        radio(payment == method)
                    }
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Order summary")

            VStack(spacing: 12) {
                ForEach(store.lines, id: \.0.id) { line in
                    HStack {
                        Text("\(line.1) × \(line.0.name)")
                            .font(.subheadline)
                            .foregroundColor(.textMain)
                            .lineLimit(1)
                        Spacer()
                        Text(money(line.0.price * Double(line.1)))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.textMain)
                    }
                }

                Rectangle().fill(Color.stroke).frame(height: 1)

                summaryRow("Subtotal", money(store.total))
                if store.discount > 0 {
                    summaryRow("Discount", "-" + money(store.discount), tint: green)
                }
                summaryRow(
                    "Delivery",
                    store.deliveryFee == 0 ? "Free" : money(store.deliveryFee),
                    tint: store.deliveryFee == 0 ? green : nil
                )
                if priority {
                    summaryRow("Priority", money(priorityFee))
                }

                Rectangle().fill(Color.stroke).frame(height: 1)

                HStack {
                    Text("Total")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.textMain)
                    Spacer()
                    Text(money(finalTotal))
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.textMain)
                }
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.stroke, lineWidth: 1)
            )
            .animation(.easeOut(duration: 0.25), value: priority)
        }
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

    private var placeBar: some View {
        Button(action: placeOrder) {
            ZStack {
                if loading {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Text("Place order")
                        Spacer()
                        Text(money(finalTotal))
                        Image(systemName: "arrow.right")
                    }
                    .padding(.horizontal, 20)
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.coral)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.coral.opacity(0.35), radius: 14, y: 6)
        }
        .buttonStyle(PressStyle())
        .disabled(loading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.paper
                .shadow(color: .black.opacity(0.05), radius: 12, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func placeOrder() {
        guard !loading else { return }
        loading = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            loading = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.easeInOut(duration: 0.4)) {
                placed = true
            }
        }
    }
}

struct TrackingView: View {
    let total: Double
    let minutes: Int
    let orderNumber: String
    let addressName: String
    var onDone: () -> Void = {}

    @State private var step = 1
    @State private var pop = false
    @State private var ring = false
    @State private var appeared = false

    private let ticker = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let green = Color(hex: 0x2E8B57)

    private let steps: [(title: String, detail: String)] = [
        ("Order placed", "We've sent it to the kitchen"),
        ("Preparing your food", "Fresh and made to order"),
        ("On the way", "Your courier is heading to you"),
        ("Delivered", "Enjoy your meal")
    ]

    private let routeProgress: [CGFloat] = [0.04, 0.34, 0.68, 1.0]

    private var remaining: Int {
        minutes * (3 - step) / 3
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                badge.padding(.top, 36)

                VStack(spacing: 6) {
                    Text(step == 3 ? "Enjoy your meal!" : "Order confirmed")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.textMain)
                    Text(step == 3 ? "Delivered to \(addressName)" : "Arriving in \(remaining) min")
                        .font(.subheadline)
                        .foregroundColor(.muted)
                    Text("Order #\(orderNumber) · \(money(total))")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.muted)
                        .padding(.horizontal, 12)
                        .frame(height: 28)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.stroke, lineWidth: 1))
                        .padding(.top, 4)
                }
                .staggerIn(1, show: appeared)

                route.staggerIn(2, show: appeared)
                stepList.staggerIn(3, show: appeared)
                courier.staggerIn(4, show: appeared)

                Button(action: onDone) {
                    Text("Back to home")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(PressStyle())
                .padding(.top, 4)
                .staggerIn(5, show: appeared)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .onAppear {
            appeared = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.1)) {
                pop = true
            }
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                ring = true
            }
        }
        .onReceive(ticker) { _ in
            if step < 3 {
                withAnimation(.easeInOut(duration: 0.6)) {
                    step += 1
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    private var badge: some View {
        ZStack {
            Circle()
                .stroke(Color.coral.opacity(0.5), lineWidth: 2)
                .frame(width: 88, height: 88)
                .scaleEffect(ring ? 1.9 : 1)
                .opacity(ring ? 0 : 0.6)

            Circle()
                .fill(step == 3 ? green : Color.coral)
                .frame(width: 88, height: 88)
                .shadow(color: Color.coral.opacity(0.35), radius: 16, y: 8)

            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(pop ? 1 : 0.3)
        .opacity(pop ? 1 : 0)
    }

    private var route: some View {
        GeometryReader { geo in
            let inset: CGFloat = 40
            let trackWidth = geo.size.width - inset * 2
            let progress = routeProgress[step]

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.stroke)
                    .frame(width: trackWidth, height: 4)
                    .offset(x: inset)

                Capsule()
                    .fill(Color.coral)
                    .frame(width: trackWidth * progress, height: 4)
                    .offset(x: inset)

                Image(systemName: "storefront.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.muted)
                    .offset(x: 12, y: -30)

                Image(systemName: "house.fill")
                    .font(.system(size: 14))
                    .foregroundColor(step == 3 ? green : .muted)
                    .offset(x: geo.size.width - 30, y: -30)

                Image(systemName: "bicycle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.coral)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    .offset(x: inset + trackWidth * progress - 17)
            }
            .frame(maxHeight: .infinity)
            .animation(.easeInOut(duration: 1.2), value: step)
        }
        .frame(height: 110)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.stroke, lineWidth: 1)
        )
    }

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { i in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 0) {
                        stepDot(i)
                        if i < steps.count - 1 {
                            Rectangle()
                                .fill(i < step ? Color.coral : Color.stroke)
                                .frame(width: 2, height: 30)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(steps[i].title)
                            .font(.system(size: 15, weight: i <= step ? .semibold : .regular))
                            .foregroundColor(i <= step ? .textMain : .muted)
                        if i == step {
                            Text(steps[i].detail)
                                .font(.caption)
                                .foregroundColor(.muted)
                                .transition(.opacity)
                        }
                    }
                    .padding(.top, 2)

                    Spacer()
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.stroke, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func stepDot(_ i: Int) -> some View {
        if i < step || (i == step && step == 3) {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(Color.coral)
                .clipShape(Circle())
        } else if i == step {
            ZStack {
                Circle()
                    .stroke(Color.coral, lineWidth: 2)
                    .frame(width: 26, height: 26)
                Circle()
                    .fill(Color.coral)
                    .frame(width: 12, height: 12)
                    .scaleEffect(ring ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: ring)
            }
        } else {
            Circle()
                .stroke(Color.stroke, lineWidth: 2)
                .frame(width: 26, height: 26)
        }
    }

    private var courier: some View {
        HStack(spacing: 14) {
            Text("K")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color.ink)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("CYCODE INC")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textMain)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.amber)
                    Text("4.9 · Your courier")
                        .font(.caption)
                        .foregroundColor(.muted)
                }
            }

            Spacer()

            circleButton("message.fill", label: "Message courier", filled: false)
            circleButton("phone.fill", label: "Call courier", filled: true)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.stroke, lineWidth: 1)
        )
    }

    private func circleButton(_ symbol: String, label: String, filled: Bool) -> some View {
        Button {} label: {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(filled ? .white : .textMain)
                .frame(width: 44, height: 44)
                .background(filled ? Color.coral : Color.paper)
                .clipShape(Circle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(label)
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static func makeStore() -> AppStore {
        let store = AppStore()
        store.add(MenuData.items[0], quantity: 2)
        store.add(MenuData.items[4])
        return store
    }

    static var previews: some View {
        CheckoutView()
            .environmentObject(makeStore())
            .preferredColorScheme(.light)
            .previewDevice("iPhone 14")
    }
}
