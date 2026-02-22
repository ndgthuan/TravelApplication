# Travel Application

A Flutter app for managing travel plans: create plans, invite members, real-time collaborative editing, map & check-in, AI chatbot for schedule suggestions, and utilities (weather, currency exchange, translation, world clock).

---

## Requirements

- Flutter SDK ^3.9.2
- Firebase project (Auth, Firestore)
- (Optional) OpenRouteService API key, Currency API key, EmailJS for support features

---

## Installation

### 1. Clone and install dependencies

```bash
git clone <repo_url>
cd travel_application
flutter pub get
```

### 2. Configure Firebase

- Create a project at [Firebase Console](https://console.firebase.google.com)
- Enable **Authentication** (Email/Password, Google, Facebook if needed)
- Create a **Firestore Database**
- Add Android/iOS app, download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into the correct directories
- Run `flutterfire configure` or copy Firebase config files into the project
- Deploy Firestore rules: paste the content of `firestore.rules` in Firebase Console → Firestore → Rules → Publish

### 3. Environment variables (.env)

```bash
cp .env.example .env
```

Edit `.env` and add the required keys:

| Key | Description |
|-----|-------------|
| `OPENROUTE_SERVICE_API_KEY` | OpenRouteService API key (map routing) |
| `CURRENCY_TOKEN` | Currency exchange API key (e.g. exchangerate-api.com) |
| `SERVICE_ID`, `TEMPLATE_ID`, `PUBLIC_KEY`, `PRIVATE_KEY` | (Optional) EmailJS for Contact Support screen |

Missing keys may disable the corresponding features or use fallbacks (e.g. route drawing, currency loading).

### 4. Run the app

```bash
flutter run
```

---

## Project structure

- `lib/` – Flutter source code
  - `main.dart` – Entry point, DI, MaterialApp
  - `core/di/` – Dependency injection
  - `domain/` – Models, repository interfaces, services
  - `data/` – Repository implementations (Firestore, API)
  - `features/` – Feature modules: auth, account, plan, home, explore, notification, utilities
- `firestore.rules` – Firestore security rules (users, plan_created, plan_shared, plan_invites, plan_presence)
- `docs/` – Documentation (e.g. REALTIME_PLAN_EDITING.md)

---

## Main features

- **Login / Sign up**: Email, Google, Facebook
- **Plan (Itinerary)**:
  - Create/edit/delete trips, add members (Owner / Editor / Spectator)
  - Invite via email → accept → collaborative real-time editing on a shared plan
  - Optimistic locking (version), “Updated by another member” hint, presence “A, B are viewing”
- **Trip details**: Map, activity list, check-in, AI chatbot for edit suggestions
- **Home**: Popular destinations, suggestions, saved places (Firestore)
- **Explore**: Map, save/unsave places
- **Notification**: Plan invites, weather alerts
- **Utilities**: Weather, currency exchange, text translation, world clock, support (FAQ, contact)

---

## Internationalization

Uses `easy_localization`. Translation files: `lib/assets/translations/` (vi.json, en.json, etc.). Strings in code use `.tr()` (e.g. `'plan.ongoing'.tr()`).

---

## Backend (Travel Agent)

The `backend/travel_agent/` directory contains a Python service (Gemini, schedule suggestions). Run it separately; the Flutter app calls the backend API when configured. See `backend/travel_agent/` and its `.env` for API keys (Gemini, Tavily, Geoapify, etc.).

---

## Firestore

- **users/{userId}**: Profile, `saved_destinations`, `plan_created`, `plan_shared`
- **plan_invites**: Plan invitation records
- **plan_presence**: Presence by room (ownerId_planId) → viewers

See `firestore.rules` for read/write permissions.

---

## License

Private / per project policy.
