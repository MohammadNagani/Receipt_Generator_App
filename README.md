# 🚛 Receipt Generator App

A Flutter-based mobile application that allows truck companies to generate, view, and manage digital receipts with cloud support and user authentication.

---

## ✨ Features

- 📋 User Authentication via **Supabase**
- 🧾 Generate digital receipts with:
  - Sender/Recipient details
  - Truck details (Chassis, Engine No., etc.)
  - Signature support
  - Date picker and unique bill number
- 📤 Upload receipts as **PDF** to Supabase Storage
- 🕓 View Receipt History for each user
- 🔍 Search & Filter by recipient name and date range
- 📥 Download or 📂 View any receipt
- ✏️ Edit existing receipt (pre-populates old data for re-generation)

---

## 🔧 Tech Stack

| Layer          | Tech Used            |
|----------------|----------------------|
| Language       | Dart (Flutter SDK)   |
| Backend        | Supabase (Auth + Storage) |
| PDF Handling   | `pdf` & `printing` Flutter packages |
| Cloud Storage  | Supabase Storage     |
| Date Handling  | `intl` package       |
| File View      | `open_file` package  |

---
