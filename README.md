# Docuras de Maragogi - ADM

**Docuras de Maragogi - ADM** is a production‑quality Flutter application developed for a real‑world client in the tourism and local commerce sector. It provides a complete management system for a local biscuit factory, allowing the owners to track products, clients, and orders while generating professional PDF reports. This project is deployed as a desktop application and is actively used in the client’s daily operations.

---

## Purpose & Overview

The core objective of **Docuras de Maragogi - ADM** is to deliver an elegant, user‑friendly desktop solution that enables a small business to:

- Maintain a catalogue of products with pricing and stock levels.
- Record client information and manage customer relationships.
- Create and process orders comprised of multiple items.
- Generate PDFs for invoices and order summaries via an integrated PDF service.

The application emphasizes reliability, offline capability, and extensibility, built using Flutter’s desktop support (Windows and Linux) with an embedded SQLite database.

---

## Key Features

1. **Modular Architecture**
   - Organized into clear layers: data access (DAO), models, services, and UI widgets.
   - Routes managed centrally for easy navigation and future expansion.

2. **CRUD Operations**
   - Full create/read/update/delete functionality for products, clients, companies, boxes, and orders.
   - Data validation and user feedback throughout forms.

3. **PDF Generation**
   - Custom `PdfService` converts orders into professional PDF documents.
   - Supports printing and saving invoices or shipment notes.

4. **Local Persistence**
   - SQLite database lives under `sql/` with migration scripts (e.g. `001.dart`).
   - Repository pattern abstracts database operations.

5. **Responsive Desktop UI**
   - Designed primarily for Windows with Linux support; future mobile or web ports are possible.
   - Clean forms, list views, and dialogs built with Flutter’s widget library.

6. **Extensibility & Maintenance**
   - Service and repository classes make it easy to swap out storage or add new features.
   - Code is organized for readability—critical for client hand‑over.

---

## 🛠️ Building and Running

> This section is intended for developers who may need to build or test the application.

1. **Prerequisites**
   - Flutter SDK (version 3.0+ recommended).
   - Platform tooling for Windows and/or Linux (e.g. Visual Studio with C++ workload for Windows).

2. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd docuras_maragogi
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the application**
   - For Windows:
     ```bash
     flutter run -d windows
     ```
   - For Linux:
     ```bash
     flutter run -d linux
     ```

5. **Production build**
   ```bash
   flutter build windows   # or flutter build linux
   ```
   The resulting artifacts are located under `build/` and ready for packaging.

6. **Database initialization**
   - On first run, the application will create the SQLite database automatically using the migration scripts located in `sql/`.

7. **Testing**
   - A basic widget test exists at `test/widget_test.dart`. Execute via:
     ```bash
     flutter test
     ```

---

##  Repository Structure

```
lib/             # application source code
  main.dart      # entry point
  app/           # organized by data, models, pages, services, etc.
sql/             # migration scripts for SQLite
test/            # widget tests
build/           # generated build artifacts
windows/, linux/ # native platform code
```

---

## Why This Matters

**Docuras Maragogi** is not a toy project. It has been delivered, deployed, and is relied upon by a paying customer. The codebase reflects real‑world constraints: rapid iteration, maintainability, and a clear separation of concerns. Recruiters and peers can look here to see:

- A full Flutter desktop application with production features.
- Use of clean architecture patterns and modern Dart/Flutter practices.
- Demonstrated ability to deliver client‑facing software that solves business problems.

Thank you for taking the time to review this project. Please reach out if you would like to discuss details or see a live demo.

---

*Created by a dedicated developer for an actual client project; not merely a portfolio exercise.*

