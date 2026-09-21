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

## Lab Activity 5: Discussion

For Lab Activity 5, I kept Lab Activity 4's DummyJSON sign-in working and added Firebase Authentication alongside it, instead of replacing it, so both workflows can be compared directly in the same app. `UserService` now has two authentication sections: the original DummyJSON methods (`loginUser`, `saveUser`, `getUser`, `logout`) at the top, and a Firebase Auth section added underneath it with `signIn`, `createAccount`, `signOut`, `updateUsername`, `deleteAccount`, and `resetPasswordFromCurrentPassword`, matching the pattern given in the lab handout. A `LoginType` enum (`dummyJson` or `firebase`) is saved in SharedPreferences whenever either sign-in succeeds, so the rest of the app always knows which backend authenticated the current session without guessing.

**DummyJSON vs Firebase workflow.** The DummyJSON flow is a single REST call: the sign-in screen posts a username and password to `/auth/login`, gets back a flat JSON user object with an access token, and `UserService` just stores that JSON as-is in SharedPreferences. There's no real session management on the client side beyond "is there a saved user object." Firebase Auth's workflow is different: `createAccount`/`signIn` go through the `FirebaseAuth` SDK instead of a manual HTTP call, Firebase manages the session and token refresh internally, and `firebaseAuth.currentUser`/`authStateChanges()` are always the source of truth rather than something the app has to persist itself. The sign-in screen now has a segmented control to pick which backend to use, and a new `signup_screen.dart` handles Firebase registration.

**From signIn to signUp.** Signing in with Firebase only needs an email and password, since `FirebaseAuth.instance.currentUser` already tracks everything else. Signing up needed more: the handout's field list (fName, lName, age, contactNo, username, emailAddress, password) follows the same shape as DummyJSON's `/users` records, but Firebase Auth's email/password user only stores uid, email, displayName, and photoURL - it has no fields for first/last name, age, or a phone number the way DummyJSON's mock users do. So `signup_screen.dart` calls `UserService().createAccount()` to make the Firebase account, `updateUsername()` to set the display name, and then saves the remaining fields (fName, lName, age, contactNo) locally in a `FirebaseProfile` keyed by the Firebase uid, since there's no Firestore step in this lab. `profile_screen.dart` reads through a single `getUserData()` method that checks the saved `LoginType` and returns a unified `ProfileData` object, so the same screen shows either the DummyJSON user or the Firebase user plus its extra profile fields without branching logic living in the UI itself.

**Main idea for the UserService implementation.** The point of putting both flows inside one `UserService` class, instead of two separate services, is that every other screen (splash, home, cart, settings, profile) only needs to call generic methods like `isLoggedIn()` and `endSession()` and never has to know or care which backend is behind them. `isLoggedIn()` and `endSession()` both check the saved `LoginType` internally and call the right underlying method (Firebase `signOut()`/`currentUser` vs the DummyJSON `logout()`/`getUser()`), so the splash screen's persistent-login check and the Logout buttons in Settings and Profile did not need any backend-specific code added to them at all.

**Benefits of the Firebase implementation.** Firebase Auth removes the need to design and secure a login API by hand: password hashing, token issuance, and token refresh are all handled by the SDK instead of being something a student project has to reimplement or trust a mock API for. `reauthenticateWithCredential` also makes sensitive actions like changing a password or deleting an account safer by default, since Firebase forces re-entry of the current password before either action is allowed, which DummyJSON's mock endpoints have no equivalent for. The tradeoff is that Firebase Auth's user object is intentionally minimal, so any extra profile data (like the fName/lName/age/contactNo fields this lab asks for) has to be stored separately, which is why this app keeps that data in a local `FirebaseProfile` rather than assuming Firebase will hold it.
