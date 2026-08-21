# pangilinan_mobile

This Flutter project is built for Lab Activity 2.

## Lab Activity 3: Discussion

For Lab Activity 3, I kept the existing model, service, provider, screen, and widget pattern, then added cart support without replacing the working product features. The new cart screen requests only the test user's cart (user ID 5) from the DummyJSON user-cart endpoint. It shows cart totals and tappable products; selecting an item opens the existing product details screen.

The chat action is now a FloatingActionButton on the normal home screen. The cart uses its own scaffold without that button, so the chat FAB is hidden while viewing the cart and returns after navigating back. The product detail screen also sends product IDs and quantities to DummyJSON's simulated add-cart endpoint. This response is handled as a test API result, not a permanent saved cart. The project was checked with Flutter dependency resolution, analysis, and widget tests after the changes.

## Lab Activity 2 Discussion

I refactored the app to use a clean folder structure with constants, models, services, providers, screens, and widgets. The product data is loaded from a sample API and shown in a list with a search bar and details page.

### Model

I created `ProductModel` with `fromJson()` and `toJson()` so the app can safely convert API response data into Dart objects. The model handles null values and formats price and rating data.

### Service

All API logic was moved into `ProductService`. The UI no longer calls HTTP directly. The service handles loading, timeouts, and exceptions, and returns a list of `ProductModel` objects.

### Provider

`ThemeProvider` is used only for theme state. It switches light/dark mode and calls `notifyListeners()` so the UI updates instantly. The theme is saved in memory while the app runs.

### Screens

The project now has separate screens:

- `home_screen.dart` for the app shell and navigation
- `product_screen.dart` for the product list, search, and refresh
- `details_screen.dart` for product details
- `settings_screen.dart` for the theme switch and about info

### API Data Flow

1. `product_screen.dart` uses `ProductService` to fetch products.
2. The service loads JSON from the API and converts it to `ProductModel`.
3. The UI presents the list with search and refresh.
4. Tapping a card opens the details page.

### Provider and UI Updates

`ThemeProvider` is wrapped around `MaterialApp` using `ChangeNotifierProvider`. When the theme switch changes, the provider updates the app theme instantly. This keeps theme logic separate from UI widgets.

### Why this pattern is better

This design separates UI from business logic. Models keep data structures, services handle API access, and screens render content. Provider manages shared state simply without adding extra packages. This makes the app easier to read and maintain while still keeping a student-style implementation.
