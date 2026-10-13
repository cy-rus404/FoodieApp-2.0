# Foodie App

A food delivery app UI built with **SwiftUI**. It covers the full ordering flow, from the splash screen through to live order tracking, with animations on every screen.

## Screens

1. **Splash**: animated logo with pulsing rings and a loading bar
2. **Login**: email and password fields with validation, shake on error, and a loading state
3. **Home**: search, category chips, auto-scrolling promo carousel, popular dishes, and a dish grid
4. **Dish detail**: large dish hero, rating and calories, ingredients, quantity stepper, and add to cart
5. **Cart**: editable items, promo codes, and a live price summary
6. **Checkout**: delivery address, delivery speed, payment method, and order summary
7. **Order tracking**: animated confirmation, courier moving along a route, and step-by-step status

## Features

- 22 dishes across 7 categories, with live search and category filtering
- Shared cart and favourites using `ObservableObject` and `@EnvironmentObject`
- Promo codes: `FOODIE` for free delivery and `SAVE10` for 10% off
- Priority delivery option that updates the total
- Custom logo drawn in code with SwiftUI shapes
- Haptic feedback on key actions

## Requirements

- macOS with **Xcode 14** or later
- iOS **16.0** or later

## Getting started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/FoodieApp-2.0.git
   ```
2. Open `Foodie.xcodeproj` in Xcode.
3. Choose an iPhone simulator at the top of the window.
4. Press **Cmd+R** to build and run.

## Project structure

| File | Purpose |
|---|---|
| `FoodieApp.swift` | App entry point |
| `RootView.swift` | Moves between splash, login, and home |
| `SplashScreen.swift`, `PulseRing.swift` | Splash screen and its animation |
| `LogoView.swift` | The Foodie logo, drawn in code |
| `LoginView.swift` | Login screen |
| `HomeView.swift` | Home screen |
| `FoodCard.swift` | Dish card |
| `DetailView.swift` | Dish detail screen |
| `CartView.swift` | Cart screen |
| `CheckoutView.swift` | Checkout and order tracking |
| `Models.swift` | Menu data and the shared cart store |
| `Components.swift` | Reusable inputs, buttons, and animations |
| `Theme.swift` | Colours |

## Notes

- This is a UI project. Login, payments, and the courier are simulated, and there is no backend.
- Food images are emoji placeholders. They can be replaced with photos or icons by adding images named `food1`, `food2`, and so on to `Assets.xcassets`.

## Roadmap

- Search, Orders, and Profile tabs
- Sign up and forgot password screens
- Real food images
- Backend and real payments

## Author

Built by [cy-rus404](https://github.com/cy-rus404).
