

````md
# 🏄‍♂️ HikkaSurf

<p align="center">
  <b>Surf Lesson Booking & Instructor Marketplace</b><br/>
  A modern peer-to-peer mobile platform connecting surf students and instructors in Sri Lanka 🌊
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/Supabase-Backend-green?logo=supabase"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-black"/>
  <img src="https://img.shields.io/badge/Architecture-Provider-orange"/>
</p>

---

## ✨ Overview

**HikkaSurf** removes the need for third-party surf schools by enabling **direct booking between students and instructors**.

It provides:
- Real-time booking updates ⚡
- Smart availability scheduling 📅
- Instructor marketplace experience 🏄‍♂️
- Role-based dashboards 👤

---

## 📸 App Preview

<p align="center">
  <i>Add your screenshots below</i>
</p>

| Home | Instructor | Booking |
|------|------------|---------|
| ![Home](assets/screenshots/home.png) | ![Instructor](assets/screenshots/instructor_profile.png) | ![Booking](assets/screenshots/booking.png) |

| Dashboard | Notifications |
|-----------|--------------|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Notifications](assets/screenshots/notifications.png) |

---

## 🚀 Key Features

### 👤 Student Experience
- 🔍 Discover instructors with filters (rating, style, experience)
- 🧑‍🏫 View detailed instructor profiles
- 📅 Book surf sessions with time, duration, and skill level
- ⚡ Real-time booking status updates (pending → confirmed → cancelled)
- 📝 Post-session reviews and ratings
- 🔔 Instant notifications via WebSockets

### 🧑‍🏫 Instructor Experience
- 📊 Live dashboard with session analytics
- 📆 Manage weekly recurring availability
- ⛔ Override specific dates (block/open slots)
- ✅ Accept / reject booking requests
- 👥 View student booking history
- 🧾 Manage profile (bio, certifications, languages)
- ⭐ Track reviews and ratings

---

## 🧠 System Architecture

| Layer | Implementation |
|------|------|
| 🎯 State Management | Provider (ChangeNotifier) |
| 🧭 Navigation | GoRouter (role-based routing) |
| 🗄️ Backend | Supabase |
| 🧩 Database | PostgreSQL |
| ⚡ Real-Time | Supabase WebSocket Channels |
| ☁️ Storage | Supabase Storage |
| 📅 Scheduling Engine | Hybrid (Recurring + Overrides) |
| 🖼️ Image Handling | image_picker + cached_network_image |

---

## 🛠️ Tech Stack

```text
Flutter (Dart)
Supabase (Backend-as-a-Service)
PostgreSQL
Provider (State Management)
GoRouter (Navigation)
Supabase Realtime (WebSockets)
image_picker
cached_network_image
intl | table_calendar | timeago
fluttertoast | shimmer | flutter_rating_bar
````

---

## 🏗️ My Contribution

✔ Built full Flutter application from scratch
✔ Designed complete UI/UX flow for both roles
✔ Implemented 7 core providers:

* Auth
* Booking
* Availability
* Profile
* Instructor
* Review
* Notification

✔ Designed Supabase database schema
✔ Implemented role-based authentication system
✔ Built real-time notification system (WebSockets)
✔ Developed hybrid scheduling engine
✔ Integrated Supabase Storage (image upload + retrieval)
✔ Implemented GoRouter role-based navigation guards

---

## 🧩 Database Structure

* `profiles`
* `bookings`
* `availability`
* `reviews`
* `notifications`
* `instructor_details`

---

## 📱 Project Type

<p align="center">
  <b>Individual Project</b> • Mobile Application • Android & iOS
</p>

---

## 📁 Assets Setup

```
assets/
 └── screenshots/
      ├── home.png
      ├── instructor_profile.png
      ├── booking.png
      ├── dashboard.png
      └── notifications.png
```

Add this to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/screenshots/
```

---

## 🚀 Future Improvements

* 💳 Payment integration (Stripe / local gateways)
* 💬 Real-time chat system
* 🤖 AI-based instructor recommendation
* 🌍 Multi-language support (Sinhala / English)
* 📲 Firebase push notifications upgrade

---

## 👨‍💻 Developer

**Ishara Madushankha**
Flutter Developer | Mobile App Engineer | Full-Stack Enthusiast

```

---

### If you want next level upgrade 🔥
I can also make for you:
- :contentReference[oaicite:0]{index=0}
- :contentReference[oaicite:1]{index=1}
- :contentReference[oaicite:2]{index=2}
- :contentReference[oaicite:3]{index=3}

Just tell me 👍
```
