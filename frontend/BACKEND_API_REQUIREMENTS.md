# Belle Beauty Salon — Backend API Requirements

## Context for the backend team

The Flutter app (this repo) is currently a **frontend-only prototype**. Every screen
reads from hardcoded data inside its GetX controller or from a bundled local file
(`assets/data/services.json`) — there is no real backend yet. The only live network
call in the whole app is the AI chat screen, which currently calls the Groq LLM API
**directly from the client** with an API key hardcoded in source
(`lib/views/chat/chat_controller.dart`) — see the security note at the end.

This document lists every API endpoint the backend needs to implement so the app can
run against real, shared, multi-device data instead of local mock data. Endpoints are
grouped by feature/screen, with the exact request parameters and response fields the
app needs, based on the data models already used in the Flutter code
(`lib/models/*.dart`, and each screen's `*_controller.dart`).

Everything below is a requirements spec, not a locked-in contract — exact route names
can be adjusted to match your API conventions, but the **fields** listed in each
response are what the UI already expects to bind to.

---

## 1. Conventions

- **Base URL**: placeholder `https://api.bellebeautysalon.com/v1` — replace with the real host.
- **Auth**: Bearer JWT in the `Authorization: Bearer <token>` header, issued by
  `POST /auth/login` and `POST /auth/register`. Endpoints marked **Auth: required**
  need a valid token; **Auth: admin** needs a token for a user whose `role == "ADMIN"`.
- **Content type**: `application/json` for all requests/responses.
- **Dates/times**: ISO-8601 (`2026-07-22T14:30:00Z`). The app formats these for
  display itself — don't send pre-formatted strings like `"Today · 14:30"`.
- **Money**: plain numbers, no currency symbol, e.g. `"price": 180`. Currency is
  always **SP (Syrian Pound)** — the app prefixes `SP` itself when displaying.
- **IDs**: every entity (service, category, booking, offer, specialist, etc.) needs a
  stable string `id`. Today's local `services.json` already has an `id` field per
  service, but the Flutter `ServiceModel.fromJson` currently **ignores** it — the
  frontend will need a small change to keep and send `id` once these APIs exist
  (flagging this so the backend doesn't get blamed for a missing id round-trip).
- **Errors**: standard HTTP status codes, plus a JSON body:
  ```json
  { "error": { "code": "INVALID_CREDENTIALS", "message": "Email or password is incorrect." } }
  ```
- **Pagination**: any list endpoint that can grow unbounded (bookings, reviews,
  notifications) should support `?page=1&pageSize=20`, returning
  `{ "items": [...], "page": 1, "pageSize": 20, "total": 137 }`.

---

## 2. Auth & Account

Maps to: `lib/views/auth/auth_controller/auth_controller.dart`,
`lib/views/rolle/rolle_controller/role_controller.dart`,
`lib/views/profile/profile_controller/*.dart`

### POST /auth/register
Create a customer account. (Admins are not self-registered — see note below.)

**Auth:** none

**Request body**
```json
{
  "name": "Kelly Ahmed",
  "email": "kelly@belle.com",
  "phone": "0501234567",
  "password": "Belle1234"
}
```
Validation the backend must enforce (currently done client-side only, must be
duplicated server-side): name ≥ 2 chars; valid email; phone numeric, ≥7 digits;
password ≥8 chars with at least one letter and one digit; email must be unique.

**Response 201**
```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": "u_123",
    "name": "Kelly Ahmed",
    "email": "kelly@belle.com",
    "phone": "0501234567",
    "role": "CUSTOMER",
    "birthDate": null,
    "loyaltyPoints": 0
  }
}
```

### POST /auth/login
**Auth:** none

**Request body**
```json
{ "email": "kelly@belle.com", "password": "Belle1234" }
```

**Response 200**
```json
{
  "token": "eyJhbGciOi...",
  "user": {
    "id": "u_123",
    "name": "Kelly Ahmed",
    "email": "kelly@belle.com",
    "phone": "0501234567",
    "role": "CUSTOMER",
    "birthDate": null,
    "loyaltyPoints": 50
  }
}
```
**Important:** the app currently decides "admin vs customer" purely from a role the
*user picked on a screen* (`RoleController.currentRole`), then trusts it. The backend
must be the source of truth: `role` comes back from login based on the account in the
database, and the frontend routes to the admin dashboard or the customer home
screen based on the returned `role`, not on what the user clicked before logging in.

### POST /auth/logout
**Auth: required** — invalidate/blacklist the token (or client just discards it if you're using short-lived JWTs + refresh tokens).

**Response 204**

### GET /users/me
**Auth: required** — used by Profile screen.

**Response 200**
```json
{
  "id": "u_123",
  "name": "Kelly Ahmed",
  "email": "kelly@belle.com",
  "phone": "0501234567",
  "role": "CUSTOMER",
  "birthDate": "1995-04-12",
  "loyaltyPoints": 50
}
```

### PATCH /users/me
Used by the "Personal Info" screen to save profile edits.

**Auth: required**

**Request body** (any subset)
```json
{ "name": "Kelly A.", "email": "kelly@belle.com", "phone": "0501234567", "birthDate": "1995-04-12" }
```

**Response 200** — updated user object (same shape as `GET /users/me`).

### POST /users/me/change-password
Used by Settings → Change Password.

**Auth: required**

**Request body**
```json
{ "oldPassword": "Belle1234", "newPassword": "NewPass99" }
```
Server must verify `oldPassword` against the stored hash (today this comparison
happens **client-side** against a plaintext password kept in app memory — must move
entirely server-side), reject if `newPassword == oldPassword`, and enforce the same
password strength rules as registration.

**Response 200** `{ "success": true }`
**Response 400** on wrong old password / weak new password, using the standard error shape.

### DELETE /users/me
Used by Settings → Delete Account (currently a no-op `print()` in code — needs real
implementation).

**Auth: required**
**Response 204**

---

## 3. Categories & Services (Home / Category / Search)

Maps to: `lib/views/home/home_controller/home_controller.dart`,
`category_details_controller.dart`, `search_screen.dart`, `models/service_model.dart`,
`models/specialist_model.dart`.

### GET /categories
Powers the home screen category grid and the search screen's category filter.

**Auth:** none (or optional, if you want personalized ordering)

**Response 200**
```json
{
  "items": [
    { "id": "hair", "title": "Hair", "image": "https://cdn.../hair-icon.png", "servicesCount": 6 },
    { "id": "nails", "title": "Nails", "image": "https://cdn.../nails-icon.png", "servicesCount": 5 }
  ]
}
```

### GET /categories/{categoryId}/services
Powers the "Category Services" screen with sort/filter chips (`Popular`,
`Price: Low`, `Price: High`, `Quick` = duration ≤ 45 min).

**Auth:** none

**Query params**
| param | type | notes |
|---|---|---|
| `sort` | string | `popular` \| `price_asc` \| `price_desc` \| `quick` |

**Response 200**
```json
{
  "items": [
    {
      "id": "h1",
      "categoryId": "hair",
      "categoryName": "Hair",
      "serviceName": "Haircut & Style",
      "duration": "45 min",
      "durationMins": 45,
      "rating": 4.8,
      "reviewsCount": 128,
      "price": 180,
      "image": "https://cdn.../hair_section.webp",
      "about": "A professional haircut and blowdry tailored to your face shape and personal style.",
      "benefits": ["Face shape assessment", "Premium styling products", "Blow dry & finish"],
      "specialist": {
        "id": "sp_1",
        "name": "Sara Al Mansoori",
        "role": "Senior Hair Stylist",
        "rating": 4.9,
        "experienceYears": 7,
        "image": "https://cdn.../sara.jpg"
      }
    }
  ]
}
```

### GET /services/{serviceId}
Full detail for the Service Details screen (about, benefits, specialist, reviews are
fetched separately, see §4).

**Auth:** none
**Response 200** — same shape as one item above.

### GET /services/popular
Powers the home screen's "Popular Services" horizontal list.

**Auth:** none
**Query params:** `category` (optional, filters by category title, matching current
client behavior where the selected home category chip filters this list)

**Response 200** — array of service summaries (same shape as above, trimmed fields ok:
`id, serviceName, categoryName, duration, rating, price, image`).

### GET /services/search
Powers the search screen. Today the client only searches **categories** by title
substring match — recommend expanding this to also search service names, since users
will expect to search for a treatment by name, not just a category.

**Auth:** none
**Query params:** `q` (string, required)

**Response 200**
```json
{
  "categories": [{ "id": "hair", "title": "Hair", "image": "...", "servicesCount": 6 }],
  "services": [{ "id": "h1", "serviceName": "Haircut & Style", "categoryName": "Hair", "image": "...", "price": 180 }]
}
```

---

## 4. Reviews

Maps to: `service_details_controller.dart` (`reviewsList`, `submitReview`).

### GET /services/{serviceId}/reviews
**Auth:** none
**Response 200**
```json
{
  "items": [
    { "id": "r_1", "userName": "Sara M.", "comment": "Absolutely loved it — highly recommended!", "createdAt": "2026-07-20T10:00:00Z" }
  ]
}
```

### POST /services/{serviceId}/reviews
**Auth: required**
**Request body**
```json
{ "comment": "Best in town, will come back every month." }
```
`userName` should be derived server-side from the authenticated user, not sent by the client.

**Response 201** — the created review object.

---

## 5. Favorites

Maps to: `lib/views/favorite/favorite_controller/favorite_controller.dart`.

### GET /users/me/favorites/services
**Auth: required**
**Response 200** — array of service objects (same shape as §3).

### PUT /users/me/favorites/services/{serviceId}
Add to favorites (idempotent). **Auth: required** → `204`

### DELETE /users/me/favorites/services/{serviceId}
Remove from favorites. **Auth: required** → `204`

### GET /users/me/favorites/categories
/ `PUT` / `DELETE /users/me/favorites/categories/{categoryId}`
Same pattern as above, for the "favorite category" feature seen in
`FavoriteController.toggleFavoriteCategory`.

---

## 6. Booking

Maps to: `lib/views/booking/booking_controller.dart` and the `steps/` screens.

### GET /services/{serviceId}/availability
Powers the "Select Time" screen (`timeSlots` grouped into Morning/Afternoon/Evening).

**Auth: required**
**Query params:** `date` (`YYYY-MM-DD`, required)

**Response 200**
```json
{
  "date": "2026-07-25",
  "slots": [
    { "time": "09:00", "period": "Morning", "available": true },
    { "time": "10:30", "period": "Morning", "available": false },
    { "time": "12:00", "period": "Afternoon", "available": true },
    { "time": "18:00", "period": "Evening", "available": true }
  ]
}
```

### POST /bookings
Create an appointment (Booking Summary → Confirm).

**Auth: required**
**Request body**
```json
{ "serviceId": "h1", "date": "2026-07-25", "time": "09:30" }
```
Backend resolves the specialist assigned to the service, computes `amount` from the
service price, and awards loyalty points (client currently estimates
`points = round(price / 10)` — confirm this formula with the business and move it
server-side).

**Response 201**
```json
{
  "id": "bk_9001",
  "serviceId": "h1",
  "serviceName": "Bridal Makeup",
  "specialistName": "Noor Al-Sayed",
  "image": "https://cdn.../scancare.jpg",
  "date": "2026-07-25",
  "time": "09:30",
  "status": "UPCOMING",
  "amount": 600,
  "pointsEarned": 60
}
```

### GET /users/me/bookings
Powers the "My Appointments" tabs (Upcoming / Past / Cancelled).

**Auth: required**
**Query params:** `status` = `UPCOMING` \| `PAST` \| `CANCELLED` (optional filter)

**Response 200** — `{ "items": [ <booking objects as above> ] }`

### POST /bookings/{bookingId}/cancel
**Auth: required**
**Response 200** — the updated booking object with `status: "CANCELLED"`.

---

## 7. Offers

Maps to: `lib/views/offers/offers_controller.dart`.

### GET /offers
**Auth:** none

**Response 200**
```json
{
  "items": [
    {
      "id": "off_1",
      "badge": "LIMITED",
      "title": "20% Off Haircut",
      "startDate": "2026-05-16",
      "endDate": "2026-05-24",
      "discountLabel": "20%",
      "image": "https://cdn.../hair_section.webp",
      "serviceId": "h1"
    }
  ],
  "trendingTags": ["#BalayageVibes", "#HydraGlow", "#BridalSeason"]
}
```
Note: the client currently resolves "Get Offer" by `serviceCategory` + a numeric
`serviceIndex` into that category's list, which breaks if the service list is
reordered. Please return a direct `serviceId` instead so the button can deep-link
reliably to `GET /services/{serviceId}`.

---

## 8. Notifications

Maps to `home_controller.dart`'s `notifications` list (currently hardcoded, shown via
a bell icon with an unread badge).

### GET /users/me/notifications
**Auth: required**
**Response 200**
```json
{
  "items": [
    { "id": "n_1", "title": "New Offer!", "body": "Get 20% off your next haircut this week", "icon": "offer", "read": false, "createdAt": "2026-07-22T09:00:00Z" }
  ]
}
```
`icon` is one of: `offer`, `calendar`, `star`, `loyalty`.

### POST /users/me/notifications/{id}/read
**Auth: required** → `204`

---

## 9. AI Chat — move the LLM call server-side

Maps to `lib/views/chat/chat_controller.dart`.

**This is a security fix, not just a feature request.** The app used to call Groq's
API directly from the Flutter client with a hardcoded key, which had been committed to
git history — anyone with repo access (or anyone who finds it in a decompiled app
binary) could use it. That key must be revoked at console.groq.com if it hasn't been
already. The backend now owns the key and proxies the chat instead:

### POST /chat/message
**Auth: required** (or at least rate-limited per-device if you want anonymous chat)
**Request body**
```json
{
  "message": "What's the price range for a facial?",
  "history": [{ "role": "user", "content": "Hi" }, { "role": "assistant", "content": "Hello! How can I help?" }]
}
```
Backend holds the system prompt, model choice, and Groq (or whichever LLM) key, calls
the LLM, and returns just the reply:

**Response 200**
```json
{ "reply": "Facials range from SP 220–350 depending on the treatment. Want me to help you pick one?" }
```

---

## 10. Admin — Dashboard

Maps to: `lib/views/admin/admin_controller/admin_controller.dart` (`todayRevenue`,
`bookingsToday`, `activeStaff`, `avgRating`, `weeklyRevenue`, `weeklyData`,
`recentBookings`).

### GET /admin/dashboard/stats
**Auth: admin**
**Response 200**
```json
{
  "todayRevenue": 8420.0,
  "bookingsToday": 28,
  "activeStaff": 6,
  "avgRating": 4.9,
  "weeklyRevenue": 52890.0,
  "weeklyRevenueByDay": [6800.0, 7200.0, 8100.0, 7400.0, 8420.0, 9100.0, 5870.0],
  "recentBookings": [ /* 3 most recent booking objects, see §11 shape */ ]
}
```
Confirm with the business whether `weeklyRevenueByDay` should be fixed Mon–Sun or a
rolling last-7-days window (the mock data implies the latter isn't guaranteed).

---

## 11. Admin — Categories & Services (CRUD)

Maps to `AdminController` category/service CRUD methods and
`manage_categories_screen.dart`, `manage_services_screen.dart`, `add_edit_service_screen.dart`.

### GET /admin/categories
**Auth: admin**
```json
{ "items": [{ "id": "hair", "name": "Hair", "emoji": "✂️", "serviceCount": 12, "isActive": true }] }
```

### POST /admin/categories
**Auth: admin** — body `{ "name": "Hair", "emoji": "✂️" }` → `201` created category.

### PATCH /admin/categories/{id}
**Auth: admin** — body `{ "name": "...", "emoji": "...", "isActive": true }` → `200` updated category.

### DELETE /admin/categories/{id}
**Auth: admin** → `204`. Decide server-side policy for categories that still have
services attached (block delete vs. cascade vs. orphan).

### GET /admin/services?categoryId=hair
**Auth: admin**
```json
{
  "items": [
    {
      "id": "s1", "name": "Haircut & Style", "categoryId": "hair", "price": 180,
      "durationMins": 60, "description": "Professional cut and blowdry styling session.",
      "benefits": ["Wash included", "Blowdry", "Style advice"],
      "isActive": true, "bookingsPerWeek": 12
    }
  ]
}
```

### POST /admin/services
**Auth: admin** — body is the service object minus `id`/`bookingsPerWeek` (server-computed) → `201`.

### PATCH /admin/services/{id}
**Auth: admin** — same shape, partial update → `200`.

### DELETE /admin/services/{id}
**Auth: admin** → `204` (and decrement the parent category's `serviceCount`).

---

## 12. Admin — Bookings management

Maps to `admin_bookings_screen.dart`.

### GET /admin/bookings
**Auth: admin**
**Query params:** `status` = `confirmed` \| `pending` \| `cancelled` (optional)
```json
{
  "items": [
    { "id": "b1", "clientName": "Sara Mansour", "serviceName": "Balayage", "specialistName": "Layla", "dateTime": "2026-07-22T14:30:00Z", "amount": 580, "status": "confirmed" }
  ]
}
```

### PATCH /admin/bookings/{id}/status
**Auth: admin** — body `{ "status": "confirmed" | "pending" | "cancelled" }` → `200` updated booking.

---

## 13. Admin — Availability management

Maps to `AdminController`'s `availability` map and `availability_screen.dart`
(`getSlotStatus`, `toggleSlot`, `blockLunch`, `blockDay`).

### GET /admin/availability
**Auth: admin**
**Query params:** `startDate`, `days` (e.g. 7)
```json
{
  "slots": [
    { "date": "2026-07-22", "hour": 11, "status": "booked" },
    { "date": "2026-07-22", "hour": 14, "status": "booked" },
    { "date": "2026-07-23", "hour": 12, "status": "blocked" }
  ]
}
```
`status` is one of `available` \| `booked` \| `blocked`. `booked` slots are derived
from real bookings and shouldn't be directly overridable by the toggle endpoint
below.

### PATCH /admin/availability
Toggle one slot, or bulk-block a range (covers `toggleSlot`, `blockLunch`, `blockDay`
in one flexible endpoint).

**Auth: admin**
**Request body** (single slot)
```json
{ "date": "2026-07-23", "hour": 12, "status": "blocked" }
```
**Request body** (bulk block, e.g. "block lunch" or "block whole day")
```json
{ "date": "2026-07-23", "hourFrom": 12, "hourTo": 13, "status": "blocked" }
```
Server must reject attempts to set a `booked` slot to `available`/`blocked` directly
— that should only change via booking creation/cancellation.

---

## 14. Optional / lower priority — Support content

Maps to `help_support_screen.dart` (FAQ list + working hours), currently static
strings in the widget. Low priority — only build this if the business wants to edit
FAQs/hours without an app release.

### GET /support/faqs → `{ "items": [{ "question": "...", "answer": "..." }] }`
### GET /support/business-hours → `{ "items": [{ "day": "Sat–Thu", "time": "9 AM – 9 PM" }] }`

---

## 15. Security notes for the backend team

1. **Never return `password`** in any user object, ever — the current Flutter
   `UserModel` keeps a plaintext password in memory client-side (fine for a mock, not
   fine once there's a real backend). Passwords must be hashed (bcrypt/argon2) and
   never round-tripped to the client.
2. **Role must come from the server**, not from a value the client sent or a screen
   the user tapped through before logging in (see the login note in §2).
3. **Rotate the Groq API key** — it's already committed and pushed to GitHub (see §9).
4. Validate everything the client currently validates only in Dart (email format,
   password strength, phone format) again server-side — client-side validation is a
   UX nicety, not a security boundary.
