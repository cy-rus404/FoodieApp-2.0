import SwiftUI

struct PromoCard: View {
    let promo: PromoBanner

    var body: some View {
        ZStack {
            LinearGradient(
                colors: promo.colors.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.14))
                .frame(width: 210, height: 210)
                .offset(x: 120, y: -40)

            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 90, height: 90)
                .offset(x: 30, y: 74)

            HStack {
                Spacer()
                FloatingEmoji(emoji: promo.emoji, size: 104)
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 10)
                    .offset(x: 14, y: 6)
            }

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("OFFER")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.ink)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .clipShape(Capsule())
                    Text(promo.title)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .lineLimit(3)
                    Text(promo.subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: 190, alignment: .leading)
                Spacer()
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct HomeView: View {
    var onOpenCart: () -> Void = {}

    @EnvironmentObject var store: AppStore
    @State private var search = ""
    @State private var selected: FoodCategory = .all
    @State private var appeared = false
    @State private var tab = 0
    @State private var promoIndex = 0
    @State private var selectedItem: FoodItem?
    @State private var showCart = false
    @Namespace private var chipNS
    @Namespace private var tabNS

    private let promoTimer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()
    private let tabIcons = ["house.fill", "magnifyingglass", "bag", "person"]
    private let tabNames = ["Home", "Search", "Orders", "Profile"]

    private var filtered: [FoodItem] {
        MenuData.items.filter { item in
            let matchesCategory = selected == .all || item.category == selected
            let matchesSearch = search.isEmpty
                || item.name.localizedCaseInsensitiveContains(search)
                || item.restaurant.localizedCaseInsensitiveContains(search)
            return matchesCategory && matchesSearch
        }
    }

    private var popular: [FoodItem] {
        MenuData.items.filter { $0.rating >= 4.8 }
    }

    private var showFeatured: Bool {
        search.isEmpty && selected == .all
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.paper.ignoresSafeArea()

            Circle()
                .fill(Color.coral.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: 140, y: -320)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header.staggerIn(0, show: appeared)

                    searchRow.staggerIn(1, show: appeared)

                    chips.staggerIn(2, show: appeared)

                    if showFeatured {
                        promos.staggerIn(3, show: appeared)
                        popularSection.staggerIn(4, show: appeared)
                    }

                    allSection.staggerIn(5, show: appeared)
                }
                .padding(.top, 12)
                .padding(.bottom, 170)
            }

            VStack(spacing: 12) {
                if store.count > 0 {
                    cartBar
                }
                tabBar
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: store.count == 0)
        }
        .onAppear { appeared = true }
        .fullScreenCover(item: $selectedItem) { item in
            DetailView(item: item)
                .environmentObject(store)
        }
        .sheet(isPresented: $showCart) {
            CartView(onFinish: { showCart = false })
                .environmentObject(store)
        }
    }

    private var header: some View {
        let headline = Text("What are you\n").foregroundColor(.textMain)
            + Text("craving ").foregroundColor(.coral)
            + Text("today?").foregroundColor(.textMain)

        return VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.coral)
                    Text("Home")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textMain)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.muted)
                }
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.stroke, lineWidth: 1))

                Spacer()

                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .foregroundColor(.textMain)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.stroke, lineWidth: 1))
                    Circle()
                        .fill(Color.coral)
                        .frame(width: 9, height: 9)
                        .offset(x: -6, y: 6)
                }
            }

            headline
                .font(.system(size: 34, weight: .bold, design: .serif))
                .lineSpacing(2)
        }
        .padding(.horizontal, 20)
    }

    private var searchRow: some View {
        HStack(spacing: 12) {
            AppField(icon: "magnifyingglass", placeholder: "Search dishes or restaurants", text: $search)

            Button {} label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel("Filters")
        }
        .padding(.horizontal, 20)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FoodCategory.allCases) { category in
                    chip(category)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chip(_ category: FoodCategory) -> some View {
        let isOn = selected == category
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selected = category
            }
        } label: {
            Text(category.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 18)
                .frame(height: 40)
                .foregroundColor(isOn ? .white : .textMain)
                .background(
                    ZStack {
                        Capsule().fill(Color.white)
                        if isOn {
                            Capsule()
                                .fill(Color.ink)
                                .matchedGeometryEffect(id: "chip", in: chipNS)
                        }
                    }
                )
                .overlay(Capsule().stroke(Color.stroke, lineWidth: isOn ? 0 : 1))
        }
    }

    private var promos: some View {
        VStack(spacing: 12) {
            TabView(selection: $promoIndex) {
                ForEach(Array(MenuData.promos.enumerated()), id: \.offset) { index, promo in
                    PromoCard(promo: promo)
                        .padding(.horizontal, 20)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 150)
            .onReceive(promoTimer) { _ in
                withAnimation(.easeInOut(duration: 0.6)) {
                    promoIndex = (promoIndex + 1) % MenuData.promos.count
                }
            }

            HStack(spacing: 6) {
                ForEach(0..<MenuData.promos.count, id: \.self) { index in
                    Capsule()
                        .fill(index == promoIndex ? Color.ink : Color.stroke)
                        .frame(width: index == promoIndex ? 22 : 6, height: 6)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: promoIndex)
        }
    }

    private func sectionHeader(_ title: String, _ trailing: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 23, weight: .bold, design: .serif))
                .foregroundColor(.textMain)
            Spacer()
            Text(trailing)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.coral)
        }
        .padding(.horizontal, 20)
    }

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Popular near you", "Top rated")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(popular) { item in
                        FoodCard(item: item)
                            .frame(width: 172)
                            .onTapGesture { selectedItem = item }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var allSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(selected == .all ? "All dishes" : selected.rawValue, "\(filtered.count) items")

            if filtered.isEmpty {
                VStack(spacing: 8) {
                    Text("🔍").font(.system(size: 44))
                    Text("No dishes found")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(.textMain)
                    Text("Try a different word or category")
                        .font(.footnote)
                        .foregroundColor(.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible())],
                    spacing: 16
                ) {
                    ForEach(filtered) { item in
                        FoodCard(item: item)
                            .onTapGesture { selectedItem = item }
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: filtered)
            }
        }
    }

    private var cartBar: some View {
        Button(action: { showCart = true }) {
            HStack(spacing: 12) {
                Text("\(store.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.coral)
                    .frame(width: 30, height: 30)
                    .background(Color.white)
                    .clipShape(Circle())
                Text("View cart")   
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(money(store.total))
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(Color.coral)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.coral.opacity(0.35), radius: 14, y: 6)
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var tabBar: some View {
        HStack {
            ForEach(0..<4) { i in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        tab = i
                    }
                } label: {
                    ZStack {
                        if tab == i {
                            Capsule()
                                .fill(Color.coral)
                                .matchedGeometryEffect(id: "tab", in: tabNS)
                                .frame(width: 54, height: 42)
                        }
                        Image(systemName: tabIcons[i])
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(tab == i ? .white : .white.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity, minHeight: 46)
                }
                .accessibilityLabel(tabNames[i])
            }
        }
        .padding(6)
        .background(Color.ink)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
        .padding(.horizontal, 36)
        .padding(.bottom, 4)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppStore())
            .preferredColorScheme(.light)
            .previewDevice("iPhone 14")
    }
}
