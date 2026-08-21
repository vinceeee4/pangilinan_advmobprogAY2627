# pangilinan_mobile

This Flutter project is built for Lab Activity 2.

## Lab Activity 3: Discussion

For Lab Activity 3, I kept the existing model, service, provider, screen, and widget pattern, then added cart support without replacing the working product features. The new cart screen requests only the test user's cart (user ID 5) from the DummyJSON user-cart endpoint. It shows cart totals and tappable products; selecting an item opens the existing product details screen.

The chat action is now a FloatingActionButton on the normal home screen. The cart uses its own scaffold without that button, so the chat FAB is hidden while viewing the cart and returns after navigating back. The product detail screen also sends product IDs and quantities to DummyJSON's simulated add-cart endpoint. This response is handled as a test API result, not a permanent saved cart. The project was checked with Flutter dependency resolution, analysis, and widget tests after the changes.

## Lab Activity 4: Discussion

For Lab Activity 4, I added a User model and UserService to keep the authentication work separate from the screens. The sign-in screen sends credentials to the DummyJSON authentication endpoint, then UserService stores the returned user information in SharedPreferences. The splash screen checks the saved session when the app starts, so it opens Home for an authenticated user or Sign In when no session is saved.

The profile screen reads the saved User data asynchronously and displays the account image, name, email, gender, username, and user ID. The cart screen now gets that saved user ID before calling the existing cart service, which means it requests the cart for the signed-in account rather than using a fixed test ID. Logout removes only the stored authentication data, preserving the rest of the application settings. This keeps the updated design pattern clear: models represent data, services handle API and storage work, and screens focus on the interface and navigation.

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
