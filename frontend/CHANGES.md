# Belle Beauty Salon — Changes Log

This file documents all features and changes added to the project during development.

---

## 1. Role Selection Screen
**Files:** `lib/views/rolle/rolle_screen/rolle_screen.dart`, `lib/views/rolle/rolle_controller/role_controller.dart`, `lib/views/rolle/widgets/`

- Entry screen asking the user to select their role (Customer / Staff)
- Custom animated role button (`custom_role_button.dart`)
- Animated heart logo widget (`heart_logo.dart`)
- Navigates to the auth flow based on selection

---

## 2. Authentication Screens
**Files:** `lib/views/auth/auth_screen/`, `lib/views/auth/auth_controller/auth_controller.dart`, `lib/views/auth/widgets/`

- **Login screen** — email + password fields, "Forgot password" link, Google sign-in button, navigation to Create Account
- **Create Account screen** — name, email, password, confirm password fields with validation
- Shared custom widgets:
  - `custom_primary_button.dart` — gradient pink button with loading state
  - `custom_text_field.dart` — styled input with prefix icon, password toggle, validation

---

## 3. Home Screen
**Files:** `lib/views/home/home_screen/home_screen.dart`, `lib/views/home/home_controller/home_controller.dart`

- Greeting header (`home_header.dart`) with notification bell + unread badge
- Search bar (`home_search_filtter.dart`) with category quick-filter chips
- **Special Offers** horizontal `PageView` with auto-scroll (`home_offer_card.dart`)
- **Categories** 4-column grid (`home_category_item.dart`)
- **Popular Services** horizontal list (`home_popular_service_card.dart`) filtered by selected category
- Section title widget with "See All" tap (`home_section_title.dart`)
- Notification bottom sheet panel

### Popular Service Card — Heart Button (added)
- Added optional `isFavorite: bool` and `onFavoriteTap: VoidCallback?` parameters
- Heart button overlay on image top-left; filled pink when saved, outlined when not

### Popular Service Card — Navigation Fix
- Cards now pass a `ServiceModel` as `arguments` to `Get.toNamed(AppRoutes.serviceDetails)` so `ServiceDetailsController.service` is always initialized (fixes `LateInitializationError`)

### Offer Card — Overflow Fix
- Increased `SizedBox` height from `185.h` to `200.h` to resolve "BOTTOM OVERFLOWED BY 11 PIXELS" on the offer card section

---

## 4. Category Services Screen
**Files:** `lib/views/home/home_screen/category_services_screen.dart`, `lib/views/home/home_controller/category_details_controller.dart`

- Full-screen category listing with image hero header
- Filter chips row (All / Price / Rating / Duration)
- `ListView` of `ServiceListItemWidget` with animated hover lift

### Service List Item — Heart Button (added)
- Added optional `isFavorite: bool` and `onFavoriteTap: VoidCallback?` parameters
- Small circular heart button rendered above the arrow button on the right side
- Pink filled when saved; outlined faint when not
- Each item wrapped in `Obx` and wired to `FavoriteController`

---

## 5. Category Header Widget
**Files:** `lib/views/home/widget/category_section_widgets/category_header_widget.dart`

- Full-bleed background image with bottom gradient fade
- Back button + heart (favourite category) button in top bar
- Category icon (transparent background) + name + service count at bottom

### Category Favourite Button (added)
- Wrapped in `Obx`; shows filled `Icons.favorite_rounded` in primary pink when the category is saved, otherwise outlined
- Calls `FavoriteController.toggleFavoriteCategory(categoryName)` on tap

### Icon Background Fix (earlier session)
- Removed the white gradient container that was wrapping the category icon; icon now renders directly as `Image.asset` on transparent background

---

## 6. Special Offers & Trends Screen
**Files:** `lib/views/offers/offers_screen.dart`, `lib/views/offers/offers_controller.dart`

- Full-image offer cards (`_OfferDetailCard`) with gradient overlay, `LIMITED` badge, discount text, "Get Offer Now" button
- Tapping "Get Offer Now" navigates to Service Details with the relevant `ServiceModel`
- **Trending Now** section: horizontal list of hashtag chips (`_TrendingChip`)

---

## 7. Service Details Screen
**Files:** `lib/views/home/home_screen/service_details_screen.dart`, `lib/views/home/home_controller/service_details_controller.dart`

- Header image with back button and heart favourite toggle
- Service name, rating, reviews, duration, price
- About / Benefits tabs
- Specialist card
- Reviews list + add-review text field
- **Book Now** button → launches booking flow

### Bug Fix — `LateInitializationError: Field 'service' has not been initialized`

**Problem:**
`ServiceDetailsScreen` used `Get.put(ServiceDetailsController())`.
`Get.put()` returns a **cached** controller if one already exists — it does NOT create a new one.
Because of this, `onInit()` only ran once (on the very first navigation).
On every subsequent navigation to the same screen, the old controller was reused and `service` was either stale (from a previous tap) or never set (if the first navigation had no arguments).

**Root cause in plain English:**
Think of `Get.put()` like a box. The first time you call it, Flutter creates a new box and puts a fresh controller inside. The second time you call it, Flutter just gives you the same old box — it doesn't create a new one. So the `service` field inside the box never updates.

**Fix applied in `service_details_screen.dart`:**
```dart
// Before (broken — returns stale cached controller):
final controller = Get.put(ServiceDetailsController());

// After (correct — always a fresh controller):
static ServiceDetailsController _initController() {
  if (Get.isRegistered<ServiceDetailsController>()) {
    Get.delete<ServiceDetailsController>(force: true); // destroy the old box
  }
  return Get.put(ServiceDetailsController()); // create a brand new one
}
final controller = _initController();
```

**Why `static`?**
Dart runs field initializers **before** the constructor body. A static method is not tied to the instance, so it can run safely during field initialization. This guarantees the delete-then-create order is always correct.

**Fix applied in `service_details_controller.dart`:**
Changed the argument check from a loose `!= null` to a proper type check, and added a safe fallback so the app never crashes even if somehow called without arguments:
```dart
// Before:
if (Get.arguments != null) {
  service = Get.arguments as ServiceModel;
}

// After (safe type check + fallback pop):
final args = Get.arguments;
if (args is ServiceModel) {
  service = args;
} else {
  WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
}
```

**Also fixed in `home_screen.dart` (Popular Services):**
Before this fix, popular service cards were navigating without passing any data:
```dart
// Before (crash — no arguments passed):
onTap: () => Get.toNamed(AppRoutes.serviceDetails),

// After (correct — ServiceModel passed as arguments):
final serviceModel = ServiceModel(
  categoryName: s['category'] as String,
  serviceName: s['name'] as String,
  duration: s['duration'] as String,
  // ...
);
onTap: () => Get.toNamed(AppRoutes.serviceDetails, arguments: serviceModel),
```

---

## 8. Booking Flow (4 steps)
**Files:** `lib/views/booking/steps/`, `lib/views/booking/booking_confirmed_screen.dart`, `lib/views/booking/booking_controller.dart`, `lib/views/booking/steps/booking_step_app_bar.dart`

### Booking Controller
- `startBooking(service)` — sets service and navigates to Select Date
- `selectedDate`, `selectedTime` observables
- Manual date formatting (no `intl` package) using static `_months` / `_days` arrays
- Mock time slots map by period (Morning / Afternoon / Evening)
- `confirmBooking()` — navigates to Booking Confirmed

### Step 1 — Select Date (`select_date_screen.dart`)
- 14-day horizontal date picker with `_DateCard`
- Disabled "Continue" button until a date is selected (`Opacity`)

### Step 2 — Select Time (`select_time_screen.dart`)
- Time slots grouped by Morning 🌅 / Afternoon ☀️ / Evening 🌙
- Available / unavailable / selected visual states

### Step 3 — Booking Summary (`booking_summary_screen.dart`)
- Service image card, detail rows (date, time, duration, specialist)
- Total in primary pink, cancellation policy info box
- Confirm Appointment button

### Step 4 — Booking Confirmed (`booking_confirmed_screen.dart`)
- Full pink gradient background (`#FF6BA8` → `#E03372`)
- Floating decorative white bubble circles
- White checkmark circle, confirmation text
- Bottom white card: date, time, loyalty points earned
- "Back to Home" clears the navigation stack; "View Booking" goes to Appointments

### Shared AppBar (`booking_step_app_bar.dart`)
- Reusable `buildBookingAppBar(title, step)` function
- Step indicator (3 coloured bars) rendered in AppBar's `bottom:` slot to avoid `RenderFlex` overflow

---

## 9. Appointments / Booking Screen
**Files:** `lib/views/booking/booking_screen.dart`

- Animated pill tab switcher: **Upcoming / Past / Cancelled**
- Appointment card with service image, specialist name, date, time, status badge
- **Reschedule** button → shows "Coming Soon" snackbar
- **Cancel** button → confirmation dialog with:
  - "Event Busy" icon in pink circle
  - "Keep It" / "Yes, Cancel" buttons
  - 1.2 s loading spinner before confirming
  - Uses locally-scoped `RxBool isLoading` + `Obx` inside `Get.dialog`

---

## 10. Saved / Favourites Screen
**Files:** `lib/views/favorite/favorite_screen/favorite_screen.dart`, `lib/views/favorite/widget/favorite_item_widget.dart`, `lib/views/favorite/favorite_controller/favorite_controller.dart`

### Favourite Controller (expanded)
| Member | Description |
|---|---|
| `favoriteServices` | `RxList<ServiceModel>` of saved services |
| `favoriteCategories` | `RxList<String>` of saved category names |
| `isFavorite(name)` | Returns `true` if service is saved |
| `toggleFavorite(service)` | Add / remove service from list |
| `isFavoriteCategory(name)` | Returns `true` if category is saved |
| `toggleFavoriteCategory(name)` | Add / remove category from list |
| `selectedCategoryFilter` | Currently active chip filter label |
| `setFilter(category)` | Update active filter |
| `availableFilters` | `['All', ...unique categories from saved services]` |
| `filteredByCategory` | Services filtered by active chip |

### Favourite Item Widget (redesigned)
- Rounded card with drop shadow
- Pink pill category chip
- Service name (bold), duration + rating row with icons
- Price in primary pink
- Circular heart "remove" button (filled pink)

### Favourite Screen (redesigned)
- AppBar "Saved" with count badge (`3 saved`) in actions
- Category filter chips (hidden if only one category saved)
- Empty state: broken-heart icon in pink circle + helper text
- Filtered `ListView` of `FavoriteItemWidget`
- Tapping a card navigates to Service Details

---

## 11. Bottom Navigation Bar (redesigned)
**Files:** `lib/views/home/home_screen/main_screen.dart`

- Replaced Flutter's `NavigationBar` with a fully custom widget (`_NavItem`)
- Active colour: `#EC6B9D` | Inactive colour: `#B89DAA`
- Animated top-line indicator above active icon (`AnimatedContainer` width `0 → 28.w`)
- No background pill / highlight — clean transparent look
- `AnimatedScale` on icon + `AnimatedDefaultTextStyle` on label
- `ColorFilter.mode(color, BlendMode.srcIn)` for SVG icon tinting
- `BookingController` registered here via `Get.put`

---

## 12. Routes Added
**File:** `lib/constant/app_routes.dart` + `lib/app_pages.dart`

| Route constant | Path | Screen |
|---|---|---|
| `offersScreen` | `/offersScreen` | `OffersScreen` |
| `selectDate` | `/selectDate` | `SelectDateScreen` |
| `selectTime` | `/selectTime` | `SelectTimeScreen` |
| `bookingSummary` | `/bookingSummary` | `BookingSummaryScreen` |
| `bookingConfirmed` | `/bookingConfirmed` | `BookingConfirmedScreen` |

---

## 13. Global State / Bindings
**File:** `lib/bindings/initial_bindings.dart`

- `FavoriteController` registered globally with `Get.lazyPut(fenix: true)` — survives navigation and is available on any screen
- `BookingController` registered in `MainScreen` so it persists across the bottom-nav tabs

---

## 14. AI Chat Screen
**Files created:**
- `lib/views/chat/chat_message_model.dart`
- `lib/views/chat/chat_controller.dart`
- `lib/views/chat/chat_screen.dart`

**Files modified:**
- `pubspec.yaml` — added `http: ^1.2.0`
- `lib/views/home/home_screen/main_screen.dart` — replaced placeholder `Text("Chat")` with `ChatScreen()`

---

### What is this screen?

A real-time AI assistant built into the app. The user types a question and the AI replies about the salon's services, prices, and beauty tips. The conversation remembers previous messages (multi-turn) so the AI understands the context.

---

### Which AI API is used and why?

**Groq API** — using the Meta Llama 3 model, accessed through Groq's free cloud service.

| Reason | Detail |
|---|---|
| Completely free | No credit card required, no billing setup at all |
| Works everywhere | Accessible from Syria and all countries worldwide |
| Fast | Llama 3.3 70B replies in 1–2 seconds |
| Easy key | Sign up in 60 seconds at `console.groq.com` |
| OpenAI-compatible | Uses the same request/response format as OpenAI — the industry standard |

> **Why not Google Gemini?**
> We originally planned to use Google Gemini (AI Studio). However, Gemini's free tier has a quota of `0` for certain regions and API key types (Cloud Console keys starting with `AQ.`). This caused a `429 Too Many Requests` error after only 2 messages, even on the free plan. Groq has no such regional restrictions.

---

### How to activate the chat (student setup steps)

1. Open your browser and go to: **`https://console.groq.com`**
2. Sign up with Google or GitHub — **no credit card needed**
3. Click **"API Keys"** → **"Create API Key"**
4. Copy the key — it starts with `gsk_...`
5. Open `lib/views/chat/chat_controller.dart`
6. Find this line:
   ```dart
   static const _apiKey = 'YOUR_GROQ_API_KEY_HERE';
   ```
7. Replace `YOUR_GROQ_API_KEY_HERE` with your copied key
8. Hot-restart the app (or run `flutter run`) — the chat will work immediately!

The chat still opens without a key and shows a clear message telling the student what to do.

**Free plan limits:** 30 requests per minute, 14,400 per day — more than enough for a student project.

---

### File 1 — `chat_message_model.dart`

This is just a **data container** (a plain Dart class). It holds one chat message.

```
ChatMessage
 ├── text        → the message content
 ├── isUser      → true = sent by the user, false = sent by the bot
 ├── time        → when the message was created (DateTime)
 ├── isError     → true if the message is an API error notice
 └── formattedTime → getter that returns "HH:MM" as a string
```

**Why a separate file?**
Keeping the data model in its own file follows the **separation of concerns** principle. The model doesn't know about the UI or the API — it just holds data.

---

### File 2 — `chat_controller.dart`

This is the **brain** of the chat. It uses GetX (`extends GetxController`) and handles:

#### Reactive state (observable variables)
```dart
final messages   = <ChatMessage>[].obs;  // list of all chat messages
final isTyping   = false.obs;            // true while waiting for AI reply
```
Any widget wrapped in `Obx(...)` will automatically rebuild when these change.

#### `onInit()` — runs once when the controller is created
Adds the welcome message to the list immediately so the screen is never empty.

#### `sendMessage()` — the main function
Step-by-step what happens when the user taps Send:

```
1. Read text from the input field
2. Clear the input field
3. Add the user's message to the messages list (appears instantly in UI)
4. Set isTyping = true  → shows the bouncing dots animation
5. Send an HTTP POST request to the Groq API
6. Wait for the response (up to 20 seconds timeout)
7. If success (status 200) → add the AI reply to the messages list
8. If error (status 400) → bad API key, show error message
9. If any other error → network problem, show error message
10. Set isTyping = false → hides the bouncing dots
11. Scroll to the bottom of the message list
```

#### `_buildHistory()` — prepares the conversation for the API
The Groq API needs the full conversation history so it can understand the context. This function converts the `messages` list into the JSON format the API expects (OpenAI format):
```json
[
  { "role": "system",    "content": "You are a beauty assistant..." },
  { "role": "user",      "content": "Hello" },
  { "role": "assistant", "content": "Hi! How can I help?" },
  { "role": "user",      "content": "What are your prices?" }
]
```
The **system** role is always first — it tells the AI who it is and how to behave. It skips the welcome message at index 0 and skips any error messages.

#### `_systemPrompt` — the AI's instructions
A multi-line string that tells the AI who it is, what the salon offers, and how to behave. Edit this string to match the real salon's information.

#### `clearChat()` — resets the conversation
Clears all messages and adds a fresh greeting.

#### `_scrollToBottom()` — auto-scroll
Uses `WidgetsBinding.instance.addPostFrameCallback` to scroll AFTER the new message widget is built (you can't scroll before the widget exists in the list).

---

### File 3 — `chat_screen.dart`

The **UI layer**. Divided into small focused widgets:

#### `ChatScreen` (main widget)
Builds the Scaffold with three sections stacked vertically:
```
┌─────────────────────────────┐
│         AppBar               │  ← bot avatar, name, "online" dot, clear button
├─────────────────────────────┤
│       _MessageList           │  ← scrollable list of chat bubbles
│                              │
│       _SuggestionChips       │  ← shown only before first user message
│                              │
├─────────────────────────────┤
│     _TypingIndicator         │  ← bouncing dots row (hidden when not typing)
├─────────────────────────────┤
│        _InputBar             │  ← text field + send button
└─────────────────────────────┘
```

#### `_MessageList`
A `ListView.builder` driven by `controller.messages`. Passes each `ChatMessage` to `_ChatBubble`. Shows `_SuggestionChips` when only the welcome message exists.

#### `_SuggestionChips`
Five pre-written question buttons shown before the first user message. Tapping one fills the input and calls `sendMessage()` automatically.

#### `_ChatBubble`
Renders one message. The visual style changes based on `message.isUser`:

| Property | User message | Bot message |
|---|---|---|
| Position | Right side | Left side |
| Background | Pink gradient | White |
| Text colour | White | Dark |
| Corner shape | Top-right flat | Top-left flat |
| Avatar | Pink person icon | Gradient star icon |

Error messages (from failed API calls) use a yellow background so students can tell them apart from normal bot replies.

#### `_BouncingDots` (typing animation)
A `StatefulWidget` with a `SingleTickerProviderStateMixin`. Uses an `AnimationController` that loops every 1 second. Each dot reads the animation value at a different phase offset (`i / 3`) to create a wave effect:
```dart
final phase = (_ctrl.value + i / 3) % 1.0;
final t = phase < 0.5 ? phase * 2 : (1 - phase) * 2; // 0 → 1 → 0
Transform.translate(offset: Offset(0, -5 * t), ...) // moves dot up and down
```

#### `_InputBar`
- `TextField` with `maxLines: null` so it grows with long text
- `onSubmitted` calls `sendMessage()` (allows pressing Enter on keyboard)
- Send button becomes a `CircularProgressIndicator` while `isTyping` is true, so the user knows the AI is working

---

### How the HTTP request works (plain English)

The app sends a **POST request** to Groq's servers. Think of it like filling out a form and submitting it:

```
URL:  https://api.groq.com/openai/v1/chat/completions

Headers:
  Content-Type: application/json
  Authorization: Bearer gsk_...YOUR_KEY...    ← proves who you are

Body (JSON):
{
  "model": "llama-3.3-70b-versatile",
  "messages": [
    { "role": "system",    "content": "You are a beauty assistant..." },
    { "role": "user",      "content": "What services do you have?" }
  ],
  "max_tokens": 400,     ← max length of the reply
  "temperature": 0.75    ← 0 = robotic/exact, 1 = creative/random
}
```

Groq processes the request and sends back a JSON response. The app reads:
```dart
data['choices'][0]['message']['content']
```
That path navigates through Groq's response structure to get just the text string of the reply.

**Groq vs Gemini format (for reference):**

| | Gemini | Groq (OpenAI) |
|---|---|---|
| Auth | `?key=API_KEY` in URL | `Authorization: Bearer KEY` in header |
| System prompt | `system_instruction: { parts: [...] }` | First message with `role: "system"` |
| User/bot roles | `user` / `model` | `user` / `assistant` |
| Response path | `candidates[0].content.parts[0].text` | `choices[0].message.content` |

---

### New dependency added — `http` package

**File:** `pubspec.yaml`

```yaml
# Before:
google_fonts: ^6.2.1

# After:
google_fonts: ^6.2.1
http: ^1.2.0          ← NEW
```

**What `http` does:**
Flutter cannot make network requests with Dart's built-in libraries alone. The `http` package provides simple functions like `http.post(url, headers, body)` and `http.get(url)`. It is one of the most widely used packages in Flutter.

**After adding any new package, always run:**
```bash
flutter pub get
```
This downloads the package and makes it available to import in your code.

---

### Concept summary for students

| Concept | Where it's used | What you learn |
|---|---|---|
| REST API | `chat_controller.dart` | How apps talk to external services over the internet |
| JSON | `chat_controller.dart` | How data is structured when sent/received over HTTP |
| `async` / `await` | `sendMessage()` | How to write code that waits for a response without freezing the app |
| Observable state | `messages.obs`, `isTyping.obs` | How GetX rebuilds only the affected widgets |
| `StatefulWidget` + `AnimationController` | `_BouncingDots` | How to create smooth custom animations |
| Separation of concerns | 3 separate files | Model (data), Controller (logic), Screen (UI) — each has one job |
| `timeout()` | API call | How to stop waiting if the server takes too long |

---

## 15. Profile Screen — Menu Changes
**File:** `lib/views/profile/profile_screen/profile_screen.dart`

### Items removed
| Item | Reason |
|---|---|
| **Loyalty Points** menu item | Feature not implemented yet — removed to avoid confusing users with a dead tap |
| **Payment Methods** menu item | No payment integration in this version — removed to keep the menu clean |

### Items wired up (now navigate to real screens)
| Item | Navigates to |
|---|---|
| **Help & Support** | `AppRoutes.helpSupport` → `HelpSupportScreen` |
| **Privacy Policy** | `AppRoutes.privacyPolicy` → `PrivacyPolicyScreen` |

### New routes added
**Files:** `lib/constant/app_routes.dart`, `lib/app_pages.dart`

```dart
// app_routes.dart
static const helpSupport  = "/helpSupport";
static const privacyPolicy = "/privacyPolicy";

// app_pages.dart
GetPage(name: AppRoutes.helpSupport,   page: () => const HelpSupportScreen()),
GetPage(name: AppRoutes.privacyPolicy, page: () => const PrivacyPolicyScreen()),
```

---

## 16. Help & Support Screen
**File:** `lib/views/profile/profile_screen/help_support_screen.dart`

A full screen accessed from Profile → Help & Support.

### Sections
- **Pink gradient banner** — icon + "How can we help?" heading
- **Contact cards** — Email and Phone displayed side by side
- **FAQ accordion** — 7 expandable questions; each question expands/collapses with an animated arrow icon (`_FaqTile` is a `StatefulWidget`)
- **Working hours card** — Saturday–Thursday 9 AM–9 PM, Friday 2 PM–9 PM

### `_FaqTile` — how the accordion works
```dart
class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;   // local state: is this tile open?

  // Tapping calls setState → _expanded flips → widget rebuilds
  // AnimatedRotation turns the arrow 180° when expanded
  // AnimatedContainer smoothly resizes the tile
}
```
This is an example of **local state** managed with `StatefulWidget` (no GetX needed — only this one widget needs to know if it's open).

---

## 17. Privacy Policy Screen
**File:** `lib/views/profile/profile_screen/privacy_policy_screen.dart`

A full screen accessed from Profile → Privacy Policy.

### Sections (10 total)
1. Information We Collect
2. How We Use Your Information
3. Information Sharing
4. Data Security
5. AI Chat Feature ← notes that chat messages go to the Groq/Llama service
6. Your Rights
7. Cookies & Analytics
8. Children's Privacy
9. Changes to This Policy
10. Contact Us

### Structure
Each section is a `_PolicySection` widget — a white rounded card with a bold title and body text. The page uses `SingleChildScrollView` so students can scroll through all sections.

---

## 18. Admin Dashboard (Role-Based)
**Files created:** `lib/views/admin/admin_controller/admin_controller.dart`, `lib/views/admin/admin_screen/`

Full admin panel shown only when a user logs in with the **ADMIN** role.

### Admin Controller (`admin_controller.dart`)
Data classes: `AdminCategory`, `AdminService`, `AdminBooking`.
Reactive lists for categories, services, bookings, and a `Map<String, String>` availability grid (`'dayOffset_hour'` → `'available'|'booked'|'blocked'`). CRUD methods for all entities plus `getSlotStatus`, `toggleSlot`, `blockLunch`, `blockDay`.

### Screens
| Screen | Route | Purpose |
|---|---|---|
| `AdminDashboardScreen` | `/adminDashboard` | Stats grid, weekly revenue bar chart, quick-nav panel, recent bookings |
| `ManageCategoriesScreen` | `/adminCategories` | List + add/edit/delete via `Get.dialog` |
| `ManageServicesScreen` | `/adminServices` | Category filter chips + service cards |
| `AddEditServiceScreen` | `/adminAddEditService` | `StatefulWidget` form — name, price (SP), duration, description, benefits |
| `AdminBookingsScreen` | `/adminBookings` | All bookings with colour-coded status badges |
| `AvailabilityScreen` | `/adminAvailability` | 7-day × 12-hour scrollable grid; tap to block/unblock |

### Role Routing Fix
`RoleController` was created with `Get.put()` inside `RolleScreen`. `Get.offNamed()` destroyed the screen and its controller, so by login time `isRegistered<RoleController>()` returned `false` and admins were always routed to `mainScreen`.

**Fix:** register `RoleController` permanently in `InitialBindings`:
```dart
Get.put(RoleController(), permanent: true);
```
`RolleScreen` changed to `Get.find<RoleController>()` instead of `Get.put`.

### Default Admin Credentials
Login screen shows a role-aware demo banner:
- **Customer** — `kelly@belle.com` / `Belle1234`
- **Admin** — `admin@belle.com` / `Admin1234`

Tapping the banner auto-fills the fields via `fillDemoCredentials()` / `fillAdminCredentials()`.

---

## 20. Currency Change — AED → Syrian Pounds (SP)
All price displays across the app changed from **AED** to **SP**.

**Files updated:**
`admin_dashboard_screen.dart`, `add_edit_service_screen.dart`, `manage_services_screen.dart`, `admin_bookings_screen.dart`, `favorite_item_widget.dart`, `service_list_item_widget.dart`, `service_info_cards.dart`, `service_details_screen.dart`, `booking_summary_screen.dart`, `chat_controller.dart` (system prompt price range).

Format used throughout: `SP ${value}` (e.g. `SP 5,000`).

---

## 21. Home Search Filter — Functional
**Files modified:**
- `lib/views/home/widget/home_search_filtter.dart`
- `lib/views/home/home_controller/home_controller.dart`

### What was added

**`HomeController` — new reactive fields:**
```dart
final filterSortBy    = 'popular'.obs;  // 'popular' | 'price_asc' | 'price_desc' | 'rating'
final filterMinRating = 0.0.obs;        // 0.0 = no filter
bool get isFilterActive => filterSortBy.value != 'popular' || filterMinRating.value > 0;
void resetFilters() { ... }
```
`filteredPopularServices` now applies the rating filter and sort before returning the list.

**`HomeSearchFilter` — filter button wired up:**
- Tapping `Icons.tune_rounded` opens a modal bottom sheet
- **Sort By** chips: Most Popular | Price: Low → High | Price: High → Low | Top Rated
- **Minimum Rating** chips: Any | 4.0+ | 4.5+ | 5.0
- Selections are held in local `tempSort`/`tempMinRating` until **Apply Filters** is tapped
- "Clear all" link appears when any non-default filter is active
- Filter icon turns pink + shows a small dot **badge** when filters are active (`Obx` → `ctrl.isFilterActive`)

---

## 19. App Colours Reference
**File:** `lib/constant/app_colors.dart`

| Name | Hex | Usage |
|---|---|---|
| `primary` | `#FF4D88` | Main pink brand colour |
| `primaryDeep` | `#E03372` | Gradient end, confirmed screen |
| `primarySoft` | `#FFD1E0` | Hover states, soft borders |
| `bg` | `#FFF5F8` | Screen background |
| `chip` | `#FFE8F0` | Chip / badge backgrounds |
| `text` | `#2A0E1B` | Primary text |
| `textMuted` | `#7A5A6A` | Secondary text |
| `textFaint` | `#B89DAA` | Placeholder / inactive icons |
| `line` | `#F2DDE5` | Dividers, card borders |
| `gold` | `#F7C948` | Star rating icon |
