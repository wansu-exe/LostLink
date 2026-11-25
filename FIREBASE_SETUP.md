# LostLink – Firebase Integration Guide

Follow these steps **in order** (mirrors the build order in the PDF plan).

---

## Step 1 – Firebase Console Setup

1. Go to https://console.firebase.google.com and click **Add project**.
2. Name it `lostlink-nexora`, disable Google Analytics (not needed), click **Create project**.

### Enable Authentication
1. Left sidebar → **Build → Authentication → Get started**.
2. Click **Email/Password** → Enable → Save.

### Create Firestore Database
1. Left sidebar → **Build → Firestore Database → Create database**.
2. Choose **Start in test mode** (you will replace this with real rules before the demo).
3. Pick a region (e.g. `asia-southeast1` for the Philippines) → Enable.

### Create Storage Bucket
1. Left sidebar → **Build → Storage → Get started**.
2. Accept the default rules → Choose the same region → Done.

---

## Step 2 – Register Your Android App

1. On the project overview, click the **Android icon**.
2. Enter your package name (e.g. `com.nexora.lostlink`).
3. For **SHA-1**, run this in your project root:
   ```
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 from the `debug` variant.
4. Click **Register app** → Download **google-services.json** →
   place it at `android/app/google-services.json`.

---

## Step 3 – Flutter / FlutterFire Setup

```bash
# Install Firebase CLI (requires Node.js)
npm install -g firebase-tools
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In your project root, run:
flutterfire configure --project=lostlink-nexora
```

This generates `lib/firebase_options.dart` automatically.

Then install the Flutter packages:

```bash
flutter pub get
```

---

## Step 4 – Replace Mock Files with Firebase Files

After running `flutterfire configure`, swap these files:

| Delete / rename (mock)         | Use instead (Firebase)                  |
|--------------------------------|-----------------------------------------|
| `lib/main.dart`                | `lib/main_firebase.dart` → rename to `main.dart` |
| `lib/screens/login_screen.dart`    | `login_screen_firebase.dart`        |
| `lib/screens/register_screen.dart` | `register_screen_firebase.dart`     |
| `lib/screens/home_screen.dart`     | `home_screen_firebase.dart`         |
| `lib/screens/report_screen.dart`   | `report_screen_firebase.dart`       |

The `auth_gate.dart` file is new — no replacement needed, just add it.

---

## Step 5 – Apply Security Rules

### Firestore rules
1. Firebase Console → **Firestore → Rules** tab.
2. Copy the contents of `firestore.rules` and paste → **Publish**.

### Storage rules
1. Firebase Console → **Storage → Rules** tab.
2. Copy the contents of `storage.rules` and paste → **Publish**.

---

## Step 6 – Set an Admin Account (Manual)

1. Register a user through the app using the security office's email.
2. Firebase Console → **Firestore → users collection** → find that user's document.
3. Click the document → Edit → change `role` from `"user"` to `"admin"` → Update.

That account now sees the Admin Review Dashboard (you can build this next).

---

## Step 7 – Test on a Real Device

```bash
flutter run --release
```

Check these flows in order:
- [ ] Register a new account → document appears in Firestore `/users`
- [ ] Login / logout
- [ ] Submit a Lost report (text only) → document appears in `/items`
- [ ] Submit a Found report with a photo → photo appears in Storage, URL in document
- [ ] Home Feed updates live when a second device submits a report
- [ ] Search returns results
- [ ] Submit a claim → document appears in `/claims`

---

## Firestore Data Structure (reference)

```
/users/{uid}
  name: string
  email: string
  role: "user" | "admin"
  createdAt: timestamp

/items/{itemId}
  id: string
  name: string
  description: string
  location: string
  status: "lost" | "found"
  category: string
  reportedByUid: string
  reportedByName: string
  photoUrl: string | null
  date: ISO-8601 string
  createdAt: timestamp
  claimStatus: "open" | "claimed" | "returned"

/claims/{claimId}
  id: string
  itemId: string
  claimedByUid: string
  claimedByName: string
  proofDescription: string
  status: "pending" | "approved" | "rejected"
  createdAt: timestamp
```

---

## Budget / Quota Notes (Spark / free plan)

| Feature | Free quota | LostLink usage |
|---|---|---|
| Authentication | Unlimited | ✅ Fine |
| Firestore reads | 50 000 / day | ✅ Fine for campus use |
| Firestore writes | 20 000 / day | ✅ Fine |
| Storage | 5 GB stored, 1 GB/day download | ⚠️ Set a budget alert |

Images are compressed to 70% quality and max 1024 px wide before upload
(configured in `StorageService`) to stay well within the free quota.
