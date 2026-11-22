# Stark Group — Vehicle Management System (VMS)

An enterprise-grade, frontend-only **Vehicle Management System (VMS)** built with **Flutter Web**. This application provides a responsive fleet administration interface strictly powered by in-memory mock state and adhering to the official **Stark Group Design System**.

---

## 📌 Scope & Architecture Boundaries

* **Frontend UI & Mock State ONLY**: Contains no HTTP clients, backend APIs, external auth services, or database connections.
* **In-Memory Reactive State**: Powered by Flutter's native `ChangeNotifier` and `InheritedNotifier` (`VmsState` & `VmsScope`) with zero external package bloat.
* **Modular Architecture**: Strictly separates tokens, models, mock state stores, reusable atomic components, and screens.

---

## 🎨 Design System & Color Tokens

Color is used strictly to communicate hierarchy, actions, and status—never as arbitrary ornamentation.

| Token | Hex Code | Visual Preview | Application & Role |
| :--- | :--- | :---: | :--- |
| **Deep Blue** | `#1F4E79` | `rgb(31, 78, 121)` | Persistent navigation sidebar, page headings, modal titles, and structural headers. |
| **Corporate Blue** | `#5B9BD5` | `rgb(91, 155, 213)` | Primary action buttons (e.g., `Register Vehicle`), active highlights, and focus rings. Hover state: `#4A8BC4`. |
| **Soft Gray** | `#F5F7FA` | `rgb(245, 247, 250)` | Main page background and workspace container. |
| **White** | `#FFFFFF` | `rgb(255, 255, 255)` | Elevated/bordered surfaces for cards, forms, login container, and data tables with subtle 1px borders (`#E5E7EB`). |
| **Charcoal** | `#1F2937` | `rgb(31, 41, 55)` | Primary body text, table cell values, and top-aligned form labels. |
| **Green** | `#2E7D32` | `rgb(46, 125, 50)` | **Active / Success status badges ONLY** (soft green pill `#E8F5E9` with `#2E7D32` dot & text). |
| **Red** | `#D32F2F` | `rgb(211, 47, 47)` | **Delete actions and form/validation error states ONLY** (soft red `#FDE8E8` container with `#D32F2F` trash icon & text). |
| **Neutral Status** | `#6B7280` | `rgb(107, 114, 128)` | Inactive status badge indicator and text on `#F3F4F6` soft gray pill. |

---

## 🖥️ Layout & Navigation Structure

* **Responsive `AppShell`**:
  * **Desktop (width ≥ 900px)**: Persistent 260px left sidebar in Deep Blue (`#1F4E79`) with VMS branding, fleet count badge, navigation links, and user profile with Sign Out.
  * **Tablet / Mobile (width < 900px)**: Automatically collapses the sidebar into a sliding drawer with a header hamburger button, preventing horizontal overflow.
* **Standard Page Header**:
  * Every workspace view has a standardized header with the page title aligned at the top left in Deep Blue (`#1F4E79`) and the primary action button aligned at the top right (e.g., `Register Vehicle` or `Back to Fleet`).

---

## 🚀 Screens & User Flows

### 1. Login Screen
* Centered White (`#FFFFFF`) card on Soft Gray (`#F5F7FA`) background with subtle shadow and 1px border.
* Top-aligned labels in Charcoal (`#1F2937`) above inputs for Email/Username and Password.
* Inline validation errors in Red (`#D32F2F`).
* Corporate Blue (`#5B9BD5`) primary Sign In button.
* Includes a **"Fill Demo Credentials"** button for immediate evaluation.

### 2. Vehicle List Screen
* Top header with page title and Corporate Blue `Register Vehicle` primary button.
* Fleet KPI summary cards (Total Registered Fleet, Active Vehicles with Green dot indicator, Inactive/Maintenance).
* Real-time search by Vehicle Number, Brand, Model, Company, or Type.
* Filter dropdowns by Status (`All`, `Active`, `Inactive`) and Company.
* White (`#FFFFFF`) data table/card container with subtle 1px borders displaying all 6 mandatory vehicle fields:
  1. `Vehicle Number` (e.g., `STK-8421`)
  2. `Company` (e.g., `Stark Logistics`, `Apex Fleet Corp`)
  3. `Type` (e.g., `Heavy Truck`, `Cargo Van`, `SUV`, `Pickup`)
  4. `Brand` (e.g., `Volvo`, `Mercedes-Benz`, `Toyota`, `Ford`)
  5. `Model` (e.g., `FH16 750`, `Sprinter 314`, `Land Cruiser 300`)
  6. `Status` (using `StatusBadge` component)
* Row actions:
  * **Edit**: Opens the pre-filled form to update the vehicle.
  * **Delete**: Soft-red button (`#D32F2F`) that opens a confirmation dialog, removes the item from mock state, and provides an Undo notification.
* Polished empty state with search reset and demo data restore.

### 3. Register / Edit Vehicle Screen
* Supports both registering a new vehicle and editing an existing one with pre-filled inputs.
* White (`#FFFFFF`) form card with top-aligned Charcoal labels, subtle borders, and Red validation messages.
* Validates all 6 mandatory fields.
* Corporate Blue primary button (`Save Vehicle` / `Update Vehicle`) and secondary `Cancel` button returning to the list.

---

## 🧱 Reusable Component Library

All extracted widgets are located in `lib/widgets/`:

| Component | File | Description |
| :--- | :--- | :--- |
| `AppShell` | `lib/widgets/app_shell.dart` | Persistent Deep Blue sidebar + top header standard + workspace container. |
| `PrimaryButton` | `lib/widgets/primary_button.dart` | Corporate Blue (`#5B9BD5`) button with hover states and leading icon support. |
| `DeleteButton` | `lib/widgets/delete_button.dart` | Soft red container with `#D32F2F` trash icon and text. |
| `StatusBadge` | `lib/widgets/status_badge.dart` | Rounded pill with indicator dot and text (`#2E7D32` for Active). |
| `LabeledFormField` | `lib/widgets/labeled_form_field.dart` | Top Charcoal label, 1px bordered field, focus ring, and inline Red error text. |
| `LabeledDropdown` | `lib/widgets/labeled_dropdown.dart` | Top Charcoal label, bordered dropdown, and inline Red validation. |
| `EmptyStateCard` | `lib/widgets/empty_state_card.dart` | Polished empty state with icon, message, and action triggers. |
| `ConfirmationDialog` | `lib/widgets/confirmation_dialog.dart` | Modal dialog for confirming vehicle deletion. |

---

## 📂 Project Structure

```text
VMS/
├── analysis_options.yaml           # Analyzer configuration (0 warnings, 0 errors)
├── pubspec.yaml                    # Flutter project configuration
├── README.md                       # Complete documentation
├── test/
│   └── widget_test.dart            # Flutter widget mounting & title smoke test
├── web/
│   ├── index.html                  # Web entry point
│   └── manifest.json               # Web PWA manifest
└── lib/
    ├── main.dart                   # Application entry point & router switcher
    ├── models/
    │   └── vehicle.dart            # Vehicle entity model with 6 mandatory fields & mock data
    ├── state/
    │   └── vms_state.dart          # In-memory ChangeNotifier & VmsScope inherited notifier
    ├── theme/
    │   ├── app_colors.dart         # Strict Stark Group VMS color tokens
    │   └── app_theme.dart          # Centralized ThemeData, typography, and input styling
    ├── widgets/
    │   ├── app_shell.dart          # Responsive navigation shell & header standard
    │   ├── confirmation_dialog.dart# Delete confirmation dialog
    │   ├── delete_button.dart      # Soft-red delete action button
    │   ├── empty_state_card.dart   # Polished empty state component
    │   ├── labeled_dropdown.dart   # Top-labeled bordered dropdown
    │   ├── labeled_form_field.dart # Top-labeled bordered text field
    │   ├── primary_button.dart     # Corporate Blue primary action button
    │   └── status_badge.dart       # Active (Green) & Inactive (Neutral) pill badge
    └── screens/
        ├── login_screen.dart       # Centered login card with inline validation
        ├── vehicle_list_screen.dart# Fleet table, KPIs, search/filter & row actions
        └── register_edit_vehicle_screen.dart # 6-field registration/edit form
```

---

## 🛠️ Prerequisites & Setup

### Requirements
* **Flutter SDK**: `>= 3.0.0` (Tested on Flutter 3.50.0 / Dart 3.14.0)
* **Web Browser**: Google Chrome, Microsoft Edge, or any modern evergreen browser.

---

## 💻 How to Run the Project

### 1. Clone & Navigate to Workspace
```bash
git clone https://github.com/your-username/VMS.git
cd VMS
```

### 2. Fetch Dependencies
```bash
flutter pub get
```

### 3. Run in Development Mode (Flutter Web)
Run directly in Chrome:
```bash
flutter run -d chrome
```

Or run using the built-in web server:
```bash
flutter run -d web-server --web-port=8080
```
Then open `http://localhost:8080` in your web browser.

---

## 🧪 Testing & Code Quality

### Run Static Analysis
```bash
flutter analyze
```
*Expected output: `No issues found!`*

### Run Widget Tests
```bash
flutter test
```
*Expected output: `All tests passed!`*

---

## 📦 Production Web Build

To generate the optimized static production bundle:

```bash
flutter build web
```

The output will be placed in `build/web/`. You can serve this static directory with any web server, e.g.:

```bash
# Using Python
python -m http.server 8080 --directory build/web

# Using Node.js npx serve
npx serve build/web
```

---

