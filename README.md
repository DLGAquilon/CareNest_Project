**CareNest**

Integrated Residential Eldercare

Management and Monitoring System

─────────────────────────────────────────

_Technical Documentation & Developer README_

Version 1.1.0 • Flutter 3.41.0 • Laravel 12

| **Component** | **Technology**                  |
| ------------- | ------------------------------- |
| Language      | Dart 3.7.0                      |
| ---           | ---                             |
| Frontend      | Flutter 3.41.0                  |
| ---           | ---                             |
| HTTP Client   | Dio 5.7.0                       |
| ---           | ---                             |
| Backend API   | Laravel 12 (PHP 8.2)            |
| ---           | ---                             |
| Auth          | Laravel Sanctum (Bearer tokens) |
| ---           | ---                             |
| Database      | MySQL via XAMPP                 |
| ---           | ---                             |
| State Mgmt    | Provider 6.1.2                  |
| ---           | ---                             |
| Navigation    | GoRouter 14.6.2                 |
| ---           | ---                             |
| Editor        | VS Code                         |
| ---           | ---                             |

# **1\. Overview**

CareNest is a cross-platform mobile application designed for residential eldercare facilities. It provides administrators and caregivers with a unified system to manage residents, log health vitals, track medications, monitor inventory, and manage caregiver assignments - all from an Android phone connected to a locally hosted API.

The system follows a client-server architecture: a Flutter mobile app communicates with a RESTful Laravel API over a local WiFi network, and all data is stored in a MySQL database hosted via XAMPP.

| **Field**      | **Value**                                                         |
| -------------- | ----------------------------------------------------------------- |
| Academic Title | Integrated Residential Eldercare Management and Monitoring System |
| ---            | ---                                                               |
| Product Name   | CareNest                                                          |
| ---            | ---                                                               |
| Version        | 1.1.0                                                             |
| ---            | ---                                                               |
| Platform       | Android (physical device, wireless debugging)                     |
| ---            | ---                                                               |
| Normal Form    | Third Normal Form (3NF)                                           |
| ---            | ---                                                               |

# **2\. System Requirements**

## **2.1 Development Machine**

| **Requirement** | **Minimum**     | **Notes**                          |
| --------------- | --------------- | ---------------------------------- |
| OS              | Windows 10 / 11 | -                                  |
| ---             | ---             | ---                                |
| RAM             | 8 GB            | 16 GB recommended for emulator use |
| ---             | ---             | ---                                |
| Disk            | 10 GB free      | Flutter SDK, XAMPP, project files  |
| ---             | ---             | ---                                |
| PHP             | 8.2.x           | Bundled with XAMPP                 |
| ---             | ---             | ---                                |
| Composer        | 2.9.x           | PHP package manager                |
| ---             | ---             | ---                                |
| Flutter SDK     | 3.41.0          | Dart 3.7.0 included                |
| ---             | ---             | ---                                |
| MySQL           | 10.4+ (MariaDB) | Provided by XAMPP                  |
| ---             | ---             | ---                                |
| VS Code         | Latest          | With Flutter + Dart extensions     |
| ---             | ---             | ---                                |

## **2.2 Target Device**

| **Requirement**    | **Value**                                     |
| ------------------ | --------------------------------------------- |
| Platform           | Android 10 (API 29) or higher                 |
| ---                | ---                                           |
| Tested Device      | BRP NX1                                       |
| ---                | ---                                           |
| Connection         | Wireless debugging (same WiFi as dev machine) |
| ---                | ---                                           |
| Developer Mode     | Must be enabled                               |
| ---                | ---                                           |
| Wireless Debugging | Must be enabled in Developer Options          |
| ---                | ---                                           |

# **3\. Project Structure**

Both projects should live inside a single parent folder for easier management in VS Code.

C:\\Projects\\CareNest\\

├── carenest-api\\ ← Laravel backend (REST API)

└── carenest_app\\ ← Flutter frontend (mobile app)

## **3.1 Backend - carenest-api (Laravel)**

carenest-api\\

├── app\\

│ ├── Http\\Controllers\\Api\\

│ │ ├── AuthController.php

│ │ ├── DashboardController.php

│ │ ├── ResidentController.php

│ │ ├── CaregiverController.php

│ │ ├── HealthLogController.php

│ │ ├── MedicationLogController.php

│ │ ├── InventoryController.php

│ │ ├── InventoryCategoryController.php

│ │ ├── FamilyContactController.php

│ │ ├── ShiftScheduleController.php

│ │ └── StatusLookupController.php

│ └── Models\\

│ ├── Administrator.php

│ ├── Caregiver.php

│ ├── Resident.php

│ ├── FamilyContact.php

│ ├── HealthLog.php

│ ├── MedicationLog.php

│ ├── Inventory.php

│ ├── InventoryCategory.php

│ ├── InventoryMonitoring.php

│ ├── ShiftSchedule.php

│ └── StatusLookup.php

├── config\\

│ ├── auth.php ← Sanctum providers for Admin + Caregiver

│ └── cors.php ← Allows all localhost:\* origins

├── routes\\

│ └── api.php ← All API route definitions

└── .env ← DB credentials and app config

## **3.2 Frontend - carenest_app (Flutter)**

carenest_app\\lib\\

├── main.dart ← App entry point + Provider setup

├── router.dart ← GoRouter routes with auth guard

├── theme\\

│ └── app_theme.dart ← Colors, typography, input styles

├── services\\

│ ├── api_service.dart ← Dio HTTP client, token management

│ └── auth_service.dart ← Login, register, logout, session restore

├── widgets\\

│ ├── app_widgets.dart ← StatCard, StatusBadge, EmptyState, etc.

│ └── main_drawer.dart ← Side navigation drawer

└── screens\\

├── auth\\ login_screen.dart, signup_screen.dart

├── dashboard_screen.dart

├── residents\\ residents, detail, form screens

├── caregivers\\ caregivers, form screens

├── health_logs\\ health log list + form screens

├── medications\\ medication list + form screens

└── inventory\\ inventory list + form screens

# **4\. Database Schema (3NF)**

Database name: gshc_management. All tables follow Third Normal Form. The schema was imported manually via phpMyAdmin using the provided DDL SQL file.

| **Table**            | **Primary Key** | **Description**                                                                        |
| -------------------- | --------------- | -------------------------------------------------------------------------------------- |
| Administrator        | AdminID         | System admin accounts - used for login and auth                                        |
| ---                  | ---             | ---                                                                                    |
| Caregiver            | StaffID         | Caregiver accounts with own auth columns (Username, Password, Email) + IsArchived flag |
| ---                  | ---             | ---                                                                                    |
| Resident             | ResidentID      | Resident records - IsArchived flag for soft archiving                                  |
| ---                  | ---             | ---                                                                                    |
| FamilyContact        | ContactID       | Emergency contacts linked to a resident (1:N)                                          |
| ---                  | ---             | ---                                                                                    |
| HealthLog            | LogID           | Vitals per resident per shift - BP, HR, Temp, SpO2, statuses                           |
| ---                  | ---             | ---                                                                                    |
| MedicationLog        | MedLogID        | Medication administration records per resident                                         |
| ---                  | ---             | ---                                                                                    |
| Inventory            | ItemID          | Supply items with category FK and quantity tracking                                    |
| ---                  | ---             | ---                                                                                    |
| InventoryCategory    | CategoryID      | Lookup table for item categories                                                       |
| ---                  | ---             | ---                                                                                    |
| Inventory_Monitoring | MonitoringID    | M:N junction - caregiver checks on inventory items                                     |
| ---                  | ---             | ---                                                                                    |
| ShiftSchedule        | ShiftID         | Day/time shift assignments per caregiver                                               |
| ---                  | ---             | ---                                                                                    |
| StatusLookup         | StatusID        | Controlled vocabulary - MedicationStatus and ResidentStatus values                     |
| ---                  | ---             | ---                                                                                    |

## **4.1 Archive Columns**

Two tables have an IsArchived column added via migration. Archived records remain in the database but are hidden from all list views.

ALTER TABLE Resident ADD COLUMN IsArchived TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE Caregiver ADD COLUMN IsArchived TINYINT(1) NOT NULL DEFAULT 0;

# **5\. Installation & Setup**

## **5.1 XAMPP + Database**

- Download and install XAMPP from apachefriends.org.
- Open XAMPP Control Panel → Start Apache and MySQL.
- Go to <http://localhost/phpmyadmin>.
- Create a new database named gshc_management.
- Import the provided eldercare_ddl_dml.sql file (Import tab).
- Run the archive_migration.sql script in the SQL tab.

## **5.2 Backend (Laravel)**

Prerequisites: PHP 8.2 in system PATH, Composer 2.9+. The zip extension must be enabled in C:\\xampp\\php\\php.ini (remove the semicolon before ;extension=zip).

cd C:\\Projects\\CareNest

composer create-project laravel/laravel carenest-api

cd carenest-api

\# Install Sanctum

composer require laravel/sanctum

php artisan vendor:publish --provider="Laravel\\Sanctum\\SanctumServiceProvider"

\# Copy provided files into the project

\# .env, routes/api.php, app/Models/\*, app/Http/Controllers/Api/\*

\# config/auth.php, config/cors.php

php artisan key:generate

php artisan config:clear

php artisan serve --host=0.0.0.0 --port=8000

ℹ Run php artisan serve with --host=0.0.0.0 so the API is reachable from the phone over WiFi. Using only localhost restricts it to the PC.

## **5.3 Frontend (Flutter)**

cd C:\\Projects\\CareNest

flutter create carenest_app

cd carenest_app

\# Copy provided files into lib/

flutter pub get

Before running, open lib/services/api_service.dart and set \_pcLocalIp to your PC's IPv4 address (find it by running ipconfig in Windows CMD, look under Wireless LAN adapter Wi-Fi).

static const String \_pcLocalIp = '192.168.x.x'; // ← your actual IP

\# Run on connected Android phone

flutter run

ℹ Both the phone and PC must be on the same WiFi network. Windows Firewall must allow inbound TCP on port 8000.

# **6\. Configuration**

## **6.1 Environment Variables (.env)**

| **Variable**              | **Value**               | **Notes**                                                 |
| ------------------------- | ----------------------- | --------------------------------------------------------- |
| APP_NAME                  | CareNest                | -                                                         |
| ---                       | ---                     | ---                                                       |
| APP_ENV                   | local                   | Change to production on deployment                        |
| ---                       | ---                     | ---                                                       |
| APP_DEBUG                 | true                    | Set to false in production                                |
| ---                       | ---                     | ---                                                       |
| APP_URL                   | <http://localhost:8000> | -                                                         |
| ---                       | ---                     | ---                                                       |
| DB_CONNECTION             | mysql                   | -                                                         |
| ---                       | ---                     | ---                                                       |
| DB_HOST                   | 127.0.0.1               | Try localhost if connection fails                         |
| ---                       | ---                     | ---                                                       |
| DB_PORT                   | 3306                    | MySQL default                                             |
| ---                       | ---                     | ---                                                       |
| DB_DATABASE               | gshc_management         | Must match phpMyAdmin DB name exactly                     |
| ---                       | ---                     | ---                                                       |
| DB_USERNAME               | root                    | XAMPP default                                             |
| ---                       | ---                     | ---                                                       |
| DB_PASSWORD               | (empty)                 | XAMPP default has no password                             |
| ---                       | ---                     | ---                                                       |
| SESSION_DRIVER            | file                    | Must be file - not database (avoids sessions table error) |
| ---                       | ---                     | ---                                                       |
| SANCTUM_STATELESS_DOMAINS | localhost               | Flutter Web dev server                                    |
| ---                       | ---                     | ---                                                       |

# **7\. API Reference**

Base URL: http://&lt;PC_LOCAL_IP&gt;:8000/api

All protected routes require the header: Authorization: Bearer &lt;token&gt;

## **7.1 Authentication (Public - no token required)**

| **Method** | **Endpoint**            | **Description**                                                          |
| ---------- | ----------------------- | ------------------------------------------------------------------------ |
| POST       | /login                  | Login with username + password. Checks Administrator then Caregiver.     |
| ---        | ---                     | ---                                                                      |
| POST       | /register               | Register a new Administrator or Caregiver account (role field required). |
| ---        | ---                     | ---                                                                      |
| POST       | /forgot-password/verify | Step 1 - verify email exists in DB, returns HMAC reset token.            |
| ---        | ---                     | ---                                                                      |
| POST       | /forgot-password/reset  | Step 2 - verify token and update password hash in DB.                    |
| ---        | ---                     | ---                                                                      |

## **7.2 Session (Protected)**

| **Method** | **Endpoint** | **Description**                                           |
| ---------- | ------------ | --------------------------------------------------------- |
| POST       | /logout      | Revoke current Bearer token.                              |
| ---        | ---          | ---                                                       |
| GET        | /me          | Return authenticated user profile (works for both roles). |
| ---        | ---          | ---                                                       |

## **7.3 Dashboard (Protected)**

| **Method** | **Endpoint** | **Description**                                                                       |
| ---------- | ------------ | ------------------------------------------------------------------------------------- |
| GET        | /dashboard   | Summary counts + only residents whose LATEST log is still Critical/Under Observation. |
| ---        | ---          | ---                                                                                   |

## **7.4 Residents (Protected)**

| **Method** | **Endpoint**                    | **Description**                                                         |
| ---------- | ------------------------------- | ----------------------------------------------------------------------- |
| GET        | /residents                      | List all active (non-archived) residents.                               |
| ---        | ---                             | ---                                                                     |
| POST       | /residents                      | Create a new resident.                                                  |
| ---        | ---                             | ---                                                                     |
| GET        | /residents/{id}                 | Get resident detail with health logs, medication logs, family contacts. |
| ---        | ---                             | ---                                                                     |
| PUT        | /residents/{id}                 | Update resident details.                                                |
| ---        | ---                             | ---                                                                     |
| DELETE     | /residents/{id}                 | Permanently delete a resident.                                          |
| ---        | ---                             | ---                                                                     |
| PATCH      | /residents/{id}/archive         | Soft-archive resident - hidden from list, data preserved.               |
| ---        | ---                             | ---                                                                     |
| PATCH      | /residents/{id}/restore         | Restore an archived resident to active.                                 |
| ---        | ---                             | ---                                                                     |
| POST       | /residents/{id}/contacts        | Add a family contact directly from the resident detail screen.          |
| ---        | ---                             | ---                                                                     |
| GET        | /residents/{id}/health-logs     | All health logs for one resident.                                       |
| ---        | ---                             | ---                                                                     |
| GET        | /residents/{id}/medication-logs | All medication logs for one resident.                                   |
| ---        | ---                             | ---                                                                     |

## **7.5 Caregivers (Protected)**

| **Method** | **Endpoint**             | **Description**                                            |
| ---------- | ------------------------ | ---------------------------------------------------------- |
| GET        | /caregivers              | List all active (non-archived) caregivers.                 |
| ---        | ---                      | ---                                                        |
| POST       | /caregivers              | Create a new caregiver.                                    |
| ---        | ---                      | ---                                                        |
| GET        | /caregivers/{id}         | Get caregiver detail with shifts and monitoring records.   |
| ---        | ---                      | ---                                                        |
| PUT        | /caregivers/{id}         | Update caregiver details.                                  |
| ---        | ---                      | ---                                                        |
| DELETE     | /caregivers/{id}         | Permanently delete a caregiver.                            |
| ---        | ---                      | ---                                                        |
| PATCH      | /caregivers/{id}/archive | Soft-archive caregiver - hidden from list, data preserved. |
| ---        | ---                      | ---                                                        |
| PATCH      | /caregivers/{id}/restore | Restore an archived caregiver.                             |
| ---        | ---                      | ---                                                        |
| GET        | /caregivers/{id}/shifts  | Get shifts assigned to one caregiver.                      |
| ---        | ---                      | ---                                                        |

## **7.6 Health Logs, Medications, Inventory (Protected)**

| **Method** | **Endpoint**          | **Description**                                                     |
| ---------- | --------------------- | ------------------------------------------------------------------- |
| GET        | /health-logs          | Paginated list of all health logs (20 per page).                    |
| ---        | ---                   | ---                                                                 |
| POST       | /health-logs          | Create a new health log entry.                                      |
| ---        | ---                   | ---                                                                 |
| PUT        | /health-logs/{id}     | Update a health log entry.                                          |
| ---        | ---                   | ---                                                                 |
| DELETE     | /health-logs/{id}     | Delete a health log entry.                                          |
| ---        | ---                   | ---                                                                 |
| GET        | /medication-logs      | Paginated list of all medication logs.                              |
| ---        | ---                   | ---                                                                 |
| POST       | /medication-logs      | Create a new medication log.                                        |
| ---        | ---                   | ---                                                                 |
| PUT        | /medication-logs/{id} | Update a medication log (e.g. change status to Taken).              |
| ---        | ---                   | ---                                                                 |
| GET        | /inventory            | List all inventory items with category.                             |
| ---        | ---                   | ---                                                                 |
| GET        | /inventory/low-stock  | Items with QuantityOnHand < 10.                                     |
| ---        | ---                   | ---                                                                 |
| POST       | /inventory            | Create a new inventory item.                                        |
| ---        | ---                   | ---                                                                 |
| PUT        | /inventory/{id}       | Update an inventory item.                                           |
| ---        | ---                   | ---                                                                 |
| GET        | /inventory-categories | List all inventory categories.                                      |
| ---        | ---                   | ---                                                                 |
| GET        | /statuses/{category}  | Get status values - category is MedicationStatus or ResidentStatus. |
| ---        | ---                   | ---                                                                 |

# **8\. Authentication Flow**

## **8.1 Login**

- Flutter sends POST /api/login with username and password.
- Laravel checks the Administrator table first, then the Caregiver table.
- On match, a Sanctum Bearer token is returned alongside the user object (id, username, email, role).
- Flutter stores the token in FlutterSecureStorage and attaches it as an Authorization header on all subsequent requests.
- On app restart, the stored token is loaded and /api/me is called to restore the session.

## **8.2 Registration**

- User selects role on Step 0 of the signup flow (Administrator or Caregiver).
- Administrator path: creates a row in the Administrator table only.
- Caregiver path: creates a row in the Caregiver table with auth columns (Username, EmailAddress, Password) plus FirstName, LastName, ContactNumber.
- A Sanctum token is returned immediately after registration - no separate login required.

## **8.3 Forgot Password (2-Step)**

- Step 1: User enters their email. Flutter calls POST /api/forgot-password/verify. Laravel checks both Administrator and Caregiver tables. If found, an HMAC token is returned along with the user's role and ID.
- Step 2: User enters a new password. Flutter calls POST /api/forgot-password/reset with the email, role, user_id, reset_token, and new password. Laravel re-derives the HMAC and compares it. If valid, it updates the Password hash in the correct table.

ℹ This is an in-app password reset - no email is sent. It works by verifying the email exists in the database before allowing the update.

# **9\. Key Features**

## **9.1 Dashboard**

- Live counts: total residents, active caregivers, low stock items, health logs filed today.
- Critical Alerts: only shows residents whose MOST RECENT health log is Critical or Under Observation. If a resident was later logged as Stable, they are automatically removed from the alert list.
- Quick action shortcuts for the three most common tasks: Add Resident, Log Vitals, Log Medication.

## **9.2 Residents**

- Searchable list showing age (calculated from BirthDate), admission date, and contact count.
- Detail screen with three tabs: Profile, Health Logs, Medications.
- Add Family Contact directly from the Profile tab - no need to navigate away.
- Archive resident with confirmation dialog - record stays in the database with all logs preserved; resident disappears from the active list.

## **9.3 Caregivers**

- Searchable list showing contact number and shift count.
- Archive caregiver with confirmation dialog - same soft-delete behaviour as residents.
- Popup menu on each card: Edit or Archive (Delete permanently is not exposed in the UI).

## **9.4 Health Logs**

- Full paginated list with vitals (BP, HR, Temp, SpO2), resident status, and medication status per entry.
- Critical entries show a pulsing red avatar for immediate visual identification.
- "Under Observation" status label is abbreviated to "Under Obs." in badges to prevent layout overflow.
- Human-readable timestamps (e.g. Apr 18, 2026 08:00) instead of raw ISO format.

## **9.5 Medications**

- Log medication administration per resident with scheduled time, dosage, and status (Taken / Refused / Pending).
- Status badges include icons for accessibility (checkmark, X, clock).
- In the Resident Detail screen, "Taken" entries have a darker green background for quick visual confirmation.

## **9.6 Inventory**

- Each item displays a stock progress bar - green above 50%, amber above 20%, red (low) below 20% of max.
- Low stock banner shown in the search bar area when any item is below 10 units.
- Low stock count badge shown on the Inventory item in the side drawer.

# **10\. Running the App**

## **10.1 Two Terminals in VS Code**

Open the CareNest parent folder in VS Code. Open two separate terminals.

Terminal 1 - Laravel:

cd carenest-api

php artisan serve --host=0.0.0.0 --port=8000

Terminal 2 - Flutter:

cd carenest_app

flutter run

## **10.2 Common Issues**

| **Error**                                            | **Cause**                                                 | **Fix**                                                                                                     |
| ---------------------------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Login failed. Check your credentials.                | api_service.dart still points to 10.0.2.2 (emulator only) | Set \_pcLocalIp to your PC's IPv4 address from ipconfig.                                                    |
| ---                                                  | ---                                                       | ---                                                                                                         |
| Internal Server Error - sessions table doesn't exist | SESSION_DRIVER=database in .env                           | Change SESSION_DRIVER to file and run php artisan config:clear.                                             |
| ---                                                  | ---                                                       | ---                                                                                                         |
| cURL error 28 - timeout on composer install          | PHP zip extension not enabled                             | In C:\\xampp\\php\\php.ini, remove ; before ;extension=zip, restart XAMPP.                                  |
| ---                                                  | ---                                                       | ---                                                                                                         |
| CORS blocked in browser                              | Flutter Web request from localhost:XXXXX rejected         | Ensure config/cors.php has allowed_origins set to \['\*'\] and run php artisan config:clear.                |
| ---                                                  | ---                                                       | ---                                                                                                         |
| DB connection refused                                | MySQL not running or wrong DB_HOST                        | Start MySQL in XAMPP Control Panel. Try switching DB_HOST between 127.0.0.1 and localhost.                  |
| ---                                                  | ---                                                       | ---                                                                                                         |
| Phone cannot reach Laravel                           | Windows Firewall blocking port 8000                       | Run: netsh advfirewall firewall add rule name="Laravel Dev" dir=in action=allow protocol=TCP localport=8000 |
| ---                                                  | ---                                                       | ---                                                                                                         |

# **11\. Flutter Dependencies**

| **Package**            | **Version** | **Purpose**                                                        |
| ---------------------- | ----------- | ------------------------------------------------------------------ |
| dio                    | ^5.7.0      | HTTP client - all API calls, token header injection                |
| ---                    | ---         | ---                                                                |
| provider               | ^6.1.2      | State management - AuthService notifies the router on login/logout |
| ---                    | ---         | ---                                                                |
| flutter_secure_storage | ^9.2.2      | Encrypted storage for Bearer token on device                       |
| ---                    | ---         | ---                                                                |
| go_router              | ^14.6.2     | Declarative routing with auth redirect guard                       |
| ---                    | ---         | ---                                                                |
| intl                   | ^0.20.1     | Date formatting utility used by formatDate() helper                |
| ---                    | ---         | ---                                                                |
| cupertino_icons        | ^1.0.8      | iOS-style icon pack (used in Material context)                     |
| ---                    | ---         | ---                                                                |

# **12\. File Deployment Quick Reference**

When applying updates from a release ZIP, copy files to these exact destinations inside the project:

## **12.1 Laravel (carenest-api)**

| **File**                    | **Destination**           |
| --------------------------- | ------------------------- |
| AuthController.php          | app/Http/Controllers/Api/ |
| ---                         | ---                       |
| DashboardController.php     | app/Http/Controllers/Api/ |
| ---                         | ---                       |
| ResidentController.php      | app/Http/Controllers/Api/ |
| ---                         | ---                       |
| CaregiverController.php     | app/Http/Controllers/Api/ |
| ---                         | ---                       |
| HealthLogController.php     | app/Http/Controllers/Api/ |
| ---                         | ---                       |
| MedicationLogController.php | app/Http/Controllers/Api/ |
| ---                         | ---                       |
| InventoryController.php     | app/Http/Controllers/Api/ |
| ---                         | ---                       |
| Resident.php                | app/Models/               |
| ---                         | ---                       |
| Caregiver.php               | app/Models/               |
| ---                         | ---                       |
| api.php                     | routes/                   |
| ---                         | ---                       |
| cors.php                    | config/                   |
| ---                         | ---                       |
| auth.php                    | config/                   |
| ---                         | ---                       |
| .env                        | project root              |
| ---                         | ---                       |

## **12.2 Flutter (carenest_app)**

| **File**                    | **Destination**          |
| --------------------------- | ------------------------ |
| main.dart                   | lib/                     |
| ---                         | ---                      |
| router.dart                 | lib/                     |
| ---                         | ---                      |
| app_theme.dart              | lib/theme/               |
| ---                         | ---                      |
| api_service.dart            | lib/services/            |
| ---                         | ---                      |
| auth_service.dart           | lib/services/            |
| ---                         | ---                      |
| app_widgets.dart            | lib/widgets/             |
| ---                         | ---                      |
| main_drawer.dart            | lib/widgets/             |
| ---                         | ---                      |
| login_screen.dart           | lib/screens/auth/        |
| ---                         | ---                      |
| signup_screen.dart          | lib/screens/auth/        |
| ---                         | ---                      |
| dashboard_screen.dart       | lib/screens/             |
| ---                         | ---                      |
| residents_screen.dart       | lib/screens/residents/   |
| ---                         | ---                      |
| resident_detail_screen.dart | lib/screens/residents/   |
| ---                         | ---                      |
| resident_form_screen.dart   | lib/screens/residents/   |
| ---                         | ---                      |
| caregivers_screen.dart      | lib/screens/caregivers/  |
| ---                         | ---                      |
| caregiver_form_screen.dart  | lib/screens/caregivers/  |
| ---                         | ---                      |
| health_log_screen.dart      | lib/screens/health_logs/ |
| ---                         | ---                      |
| health_log_form_screen.dart | lib/screens/health_logs/ |
| ---                         | ---                      |
| medication_screen.dart      | lib/screens/medications/ |
| ---                         | ---                      |
| medication_form_screen.dart | lib/screens/medications/ |
| ---                         | ---                      |
| inventory_screen.dart       | lib/screens/inventory/   |
| ---                         | ---                      |
| inventory_form_screen.dart  | lib/screens/inventory/   |
| ---                         | ---                      |
| pubspec.yaml                | project root             |
| ---                         | ---                      |

# **13\. Version History**

| **Version** | **Date** | **Changes**                                                                                                                                                                                                                                                          |
| ----------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.0.0       | Apr 2026 | Initial release - full CRUD for residents, caregivers, health logs, medications, inventory.                                                                                                                                                                          |
| ---         | ---      | ---                                                                                                                                                                                                                                                                  |
| 1.1.0       | Apr 2026 | Archive feature for residents and caregivers. Add family contact from detail screen. Real 2-step forgot password. Dashboard shows only currently-critical residents. Flutter 3.41.0 / Dart 3.7.0 upgrade. StatusBadge overflow fixes. FAB icon standardised to plus. |
| ---         | ---      | ---                                                                                                                                                                                                                                                                  |

# **14\. Developer Notes**

## **14.1 Sanctum with Two Auth Models**

CareNest uses two authenticatable models: Administrator and Caregiver. Both use HasApiTokens and are registered as separate providers in config/auth.php. Sanctum resolves the correct model from the token automatically - the /api/me endpoint checks which model instance was resolved.

## **14.2 3NF Compliance**

The database schema satisfies all three normal forms. Key design decisions: StatusLookup replaces free-text varchar status fields (MedicationStatus, ResidentStatus), InventoryCategory replaces the Category varchar, ShiftSchedule extracts the repeating shift data from Caregiver, and the circular Resident.ContactID FK was replaced with FamilyContact.ResidentID as the FK owner.

## **14.3 Critical Resident Dashboard Logic**

The dashboard does not simply query for all health logs with a critical status. Instead, it first retrieves the MAX(LogID) per resident (the most recent log), then filters that set for critical statuses. This ensures that a resident who was logged as Stable after a critical event is no longer shown as an alert.

## **14.4 Local IP Dependency**

The Flutter app connects to the Laravel API using the PC's local IP address hardcoded in api_service.dart. If the PC is assigned a different IP (e.g. after reconnecting to WiFi or switching networks), the value of \_pcLocalIp must be updated and the app rebuilt. A future improvement would be to make this configurable from a settings screen.

─────────────────────────────────────────────────────────────────

CareNest | Integrated Residential Eldercare Management and Monitoring System | v1.1.0
