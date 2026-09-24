# Animal Connect (PawCare) — Backend REST API

A secure, modular, production-ready REST API backend built with **Node.js**, **Express.js**, **MongoDB**, and **Mongoose**, designed specifically to power the **Animal Connect** (PawCare) Flutter mobile application and future Admin web dashboard.

---

## 🐾 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [Architecture & Folder Structure](#architecture--folder-structure)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Running the Server](#running-the-server)
- [Database Seeding](#database-seeding)
- [API Endpoints Reference](#api-endpoints-reference)
- [Authentication & Role-Based Access Control (RBAC)](#authentication--role-based-access-control-rbac)
- [File & Image Uploads](#file--image-uploads)
- [Testing Guide](#testing-guide)
- [Flutter Integration Guide](#flutter-integration-guide)
- [Admin Backend & Security Features](#admin-backend--security-features)
- [Production Deployment Considerations](#production-deployment-considerations)

---

## 📌 Overview

**Animal Connect** is a verified animal-care ecosystem connecting:
- Public Volunteers & Citizens
- Veterinary Hospitals
- Pet Clinics
- Animal Shelters & Sanctuaries
- Pet Care Providers (Boarding, Grooming, Foster Care)
- Medicine Delivery Providers
- Animal Welfare Donors
- Platform Administrators

The backend provides complete lifecycle management for animal distress cases, hospital medical records, verified treatment funding, mock payment processing, prescription medicine orders, shelter admissions, adoption applications, and in-app notifications.

---

## 🚀 Key Features

1. **Role-Based Access Control (RBAC)**: Support for 8 specialized roles with strict privilege segregation.
2. **Animal Case Lifecycle & Auditing**: Tracks distress reports through 10 statuses with an immutable `CaseStatusHistory` audit trail.
3. **Veterinary Facility Verification**: Facilities register and remain unverified until reviewed by an administrator. Strict check prevents self-approval.
4. **Geospatial Proximity Search**: MongoDB `2dsphere` index calculates real-time distances in kilometers for emergency facility lookups.
5. **Restricted Medical Records**: Only verified medical facilities can create and update clinical diagnoses, treatment plans, and prescribed medicines.
6. **Two-Tier Photo Verification**: Workflow for comparing volunteer accident photos with clinic admission photos to combat fraudulent treatment claims.
7. **Transparent Treatment Funding**: Checklist-driven approval system ensures treatment evidence and photo match before funding requests can be approved.
8. **Idempotent Mock Payment Gateway**: Isolated donation processing with simulated transaction IDs and support for case-specific and general funds.
9. **Prescription-Guarded Medicine Orders**: Strict validation prevents ordering controlled or prescription-only medicines without an attached prescription.
10. **Shelter Capacity Enforcement**: Protects animal welfare by preventing shelter admissions beyond configured capacity.
11. **Adoption Registry & In-App Notifications**: Complete shelter animal listing, application review, and real-time notification dispatching.

---

## 🛠 Technology Stack

- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: MongoDB (Local or MongoDB Atlas)
- **ODM**: Mongoose (v8+)
- **Authentication**: JSON Web Tokens (`jsonwebtoken`) & `bcryptjs`
- **File Storage**: Multer with local disk storage and optional Cloudinary cloud storage
- **Security**: Helmet, CORS, Express Rate Limiting, Input Validation (`express-validator`)
- **Testing**: Jest & Supertest

---

## 📂 Architecture & Folder Structure

```
animal-connect-backend/
│
├── src/
│   ├── config/
│   │   ├── db.js                 # MongoDB connection logic
│   │   ├── env.js                # Environment variable loader
│   │   └── storage.js            # Multer & Cloudinary/Local storage engine
│   │
│   ├── models/                   # Mongoose schemas & virtuals
│   │   ├── User.js
│   │   ├── VolunteerProfile.js
│   │   ├── Facility.js           # 2dsphere indexed
│   │   ├── AnimalCase.js
│   │   ├── CaseStatusHistory.js
│   │   ├── TreatmentRecord.js
│   │   ├── FundingRequest.js
│   │   ├── Donation.js
│   │   ├── ShelterAdmission.js
│   │   ├── PetCareProvider.js
│   │   ├── MedicineItem.js
│   │   ├── MedicineOrder.js
│   │   ├── Prescription.js
│   │   ├── AdoptionAnimal.js
│   │   ├── AdoptionApplication.js
│   │   ├── Notification.js
│   │   └── AuditLog.js
│   │
│   ├── controllers/              # Business logic handlers
│   │   ├── authController.js
│   │   ├── volunteerController.js
│   │   ├── caseController.js
│   │   ├── facilityController.js
│   │   ├── shelterController.js
│   │   ├── petCareController.js
│   │   ├── treatmentController.js
│   │   ├── photoVerificationController.js
│   │   ├── fundingController.js
│   │   ├── donationController.js
│   │   ├── medicineController.js
│   │   ├── adoptionController.js
│   │   ├── notificationController.js
│   │   └── adminController.js
│   │
│   ├── routes/                   # Express route definitions
│   │   ├── authRoutes.js
│   │   ├── volunteerRoutes.js
│   │   ├── caseRoutes.js
│   │   ├── facilityRoutes.js
│   │   ├── shelterRoutes.js
│   │   ├── petCareRoutes.js
│   │   ├── treatmentRoutes.js
│   │   ├── fundingRoutes.js
│   │   ├── donationRoutes.js
│   │   ├── medicineRoutes.js
│   │   ├── adoptionRoutes.js
│   │   ├── notificationRoutes.js
│   │   ├── adminRoutes.js
│   │   └── index.js
│   │
│   ├── middleware/               # Express middlewares
│   │   ├── authMiddleware.js     # JWT extraction and verification
│   │   ├── roleMiddleware.js     # RBAC role authorization
│   │   ├── uploadMiddleware.js   # Multer file handling
│   │   ├── validationMiddleware.js
│   │   ├── errorMiddleware.js    # Global error handling
│   │   └── auditMiddleware.js
│   │
│   ├── services/                 # Specialized domain services
│   │   ├── mockPaymentService.js
│   │   ├── notificationService.js
│   │   ├── photoVerificationService.js
│   │   └── auditService.js
│   │
│   ├── utils/
│   │   ├── apiResponse.js        # Standardized { success, message, data, errors }
│   │   ├── appError.js           # Custom operational error class
│   │   ├── asyncHandler.js       # Wrapper to eliminate try-catch blocks
│   │   └── idGenerator.js        # Unique readable IDs (CASE-xxx, DON-xxx, etc.)
│   │
│   ├── validators/               # express-validator schemas
│   │   ├── authValidators.js
│   │   ├── caseValidators.js
│   │   ├── facilityValidators.js
│   │   ├── treatmentValidators.js
│   │   ├── fundingValidators.js
│   │   ├── donationValidators.js
│   │   ├── medicineValidators.js
│   │   └── adoptionValidators.js
│   │
│   ├── scripts/
│   │   ├── createAdmin.js        # Initial Administrator creator
│   │   └── seed.js               # Rich demo seeder matching Flutter mock data
│   │
│   ├── app.js                    # Express application configuration
│   └── server.js                 # Application entry point & DB bootstrap
│
├── tests/                        # Automated test suites
│   ├── auth.test.js
│   ├── cases.test.js
│   ├── facilities.test.js
│   ├── funding.test.js
│   └── medicine.test.js
│
├── uploads/                      # Local uploaded files (photos/documents)
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

---

## 📋 Prerequisites

- **Node.js**: v18.x or later (`node -v`)
- **npm**: v9.x or later (`npm -v`)
- **MongoDB**: Local MongoDB Community Server running on port `27017` or a MongoDB Atlas URI.

---

## ⚙️ Installation & Setup

1. **Navigate to the backend directory**:
   ```bash
   cd animal-connect-backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure environment variables**:
   Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
   Modify `.env` if using a custom MongoDB connection or Cloudinary storage.

   Default `.env` settings:
   ```ini
   PORT=5000
   NODE_ENV=development
   CLIENT_URL=*
   MONGO_URI=mongodb://localhost:27017/animal_connect
   JWT_SECRET=animal_connect_dev_jwt_secret_key_2026_xyz
   JWT_EXPIRES_IN=7d
   STORAGE_TYPE=local
   UPLOAD_PATH=uploads
   ```

---

## 🏃 Running the Server

### Development Mode (with hot-reloading)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

### Verify Running Status
Visit in your browser or make a curl request:
```
GET http://localhost:5000/api/health
```
Response:
```json
{
  "success": true,
  "message": "Animal Connect API is healthy and operational.",
  "timestamp": "2026-09-17T04:40:00.000Z",
  "uptime": 12.34
}
```

---

## 🌱 Database Seeding

To immediately populate the backend with the exact facilities, animal cases, medicines, and adoption animals present in your Flutter app (`pawcare_provider.dart`):

```bash
npm run seed
```

This creates pre-configured accounts:
- **Volunteer**: `harsshith@animalconnect.org` / `Password@123`
- **Hospital**: `hospital@animalconnect.org` / `Password@123`
- **Shelter**: `shelter@animalconnect.org` / `Password@123`

To securely initialize the Super Administrator account:
```bash
npm run seed:admin
```
Credentials configured in `.env` (Default: `admin@animalconnect.org` / `Admin@123456`).

---

## 📡 API Endpoints Reference

### Standard Response Format
All endpoints return consistent JSON envelopes:

**Success Response (HTTP 200/201)**:
```json
{
  "success": true,
  "message": "Animal case reported successfully.",
  "data": { ... }
}
```

**Error Response (HTTP 400/401/403/404/500)**:
```json
{
  "success": false,
  "message": "Validation failed: Please verify the submitted data.",
  "errors": [
    { "field": "email", "message": "Please enter a valid email address" }
  ]
}
```

---

### 1. Authentication (`/api/auth`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/auth/register` | Public | Register new user (Volunteer, Facility, Donor) |
| `POST` | `/api/auth/login` | Public | Login with email and password |
| `POST` | `/api/auth/logout` | Private | Logout user |
| `GET` | `/api/auth/me` | Private | Get authenticated user profile |
| `PUT` | `/api/auth/profile` | Private | Update user profile |
| `PUT` | `/api/auth/change-password` | Private | Change account password |

---

### 2. Volunteer Profile (`/api/volunteers`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/volunteers/profile` | Private | Create or update volunteer profile |
| `GET` | `/api/volunteers/profile` | Private | Retrieve logged-in volunteer profile |
| `PUT` | `/api/volunteers/profile` | Private | Update capabilities and service area |
| `PUT` | `/api/volunteers/availability` | Private | Toggle availability status |

---

### 3. Animal Cases (`/api/cases`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/cases` | Private | Report animal case (supports multipart photo upload) |
| `GET` | `/api/cases` | Public | List cases (filters: status, condition, priority, pagination) |
| `GET` | `/api/cases/:id` | Public | Get single case details and audit history |
| `PUT` | `/api/cases/:id` | Private | Update case details or status |
| `DELETE` | `/api/cases/:id` | Private | Close or delete case (Reporter or Admin only) |
| `GET` | `/api/cases/:id/history` | Public | Retrieve full status transition history |
| `GET` | `/api/cases/:id/treatments` | Public | Retrieve treatment records linked to this case |

---

### 4. Facilities & Hospitals (`/api/facilities`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/facilities/hospitals/register` | Private | Register veterinary hospital (starts pending) |
| `POST` | `/api/facilities/clinics/register` | Private | Register pet clinic (starts pending) |
| `GET` | `/api/facilities/hospitals` | Public | Get verified veterinary hospitals |
| `GET` | `/api/facilities/clinics` | Public | Get verified pet clinics |
| `GET` | `/api/facilities/nearby` | Public | Search facilities by GPS coords & radius (`?latitude=&longitude=&radius=`) |
| `GET` | `/api/facilities` | Public | List facilities (filters: type, city, search) |
| `GET` | `/api/facilities/:id` | Public | Get single facility details |
| `PUT` | `/api/facilities/:id` | Private | Update facility profile (self-approval forbidden) |
| `GET` | `/api/facilities/:id/cases` | Private | View cases assigned to this facility |
| `POST` | `/api/facilities/:id/cases/:caseId/accept` | Private | Accept and admit an assigned case |

---

### 5. Shelters (`/api/shelters`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/shelters/register` | Private | Register shelter with configured capacity |
| `GET` | `/api/shelters` | Public | List animal shelters |
| `GET` | `/api/shelters/:id` | Public | Get shelter details |
| `PUT` | `/api/shelters/:id` | Private | Update shelter capacity and occupancy |
| `POST` | `/api/shelters/:id/admission-requests` | Private | Submit admission request for an animal |
| `PUT` | `/api/admission-requests/:id` | Private | Accept/reject admission request (capacity enforced) |

---

### 6. Pet Care Providers (`/api/pet-care`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/pet-care/register` | Private | Register boarding, grooming or foster service |
| `GET` | `/api/pet-care` | Public | List pet care providers with filter by serviceType |
| `GET` | `/api/pet-care/:id` | Public | Get provider details |
| `PUT` | `/api/pet-care/:id` | Private | Update provider rates and availability |
| `POST` | `/api/pet-care/:id/book` | Private | Submit pet care booking request |

---

### 7. Medical Treatment Records (`/api/treatments`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/treatments` | Private (Hospital/Clinic) | Record diagnosis, treatment plan, medicines, and medical bills |
| `GET` | `/api/treatments/:id` | Public | Get treatment details |
| `PUT` | `/api/treatments/:id` | Private (Hospital/Clinic) | Update medical progress and actual costs |

---

### 8. Treatment Funding & Verification (`/api/funding-requests`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/funding-requests` | Private (Hospital/Clinic) | Submit case funding request for review |
| `GET` | `/api/funding-requests` | Public | List funding requests |
| `GET` | `/api/funding-requests/:id` | Public | Get funding request with verification checklist |
| `POST` | `/api/funding-requests/:id/submit` | Private | Mark draft request as submitted |
| `PUT` | `/api/funding-requests/:id/review` | Private (Admin Only) | Review, approve or reject funding request |

---

### 9. Donations & Sponsorship (`/api/donations`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `GET` | `/api/donations/cases` | Public | List cases needing treatment sponsorship |
| `POST` | `/api/donations` | Public/Private | Make mock donation (case-linked or general welfare) |
| `GET` | `/api/donations/my` | Private | Get authenticated user donation history |
| `GET` | `/api/donations/:id` | Public | Get donation receipt record |

---

### 10. Medicine Delivery (`/api/medicines` & `/api/medicine-orders`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `GET` | `/api/medicines` | Public | List medicine catalog with category filter |
| `GET` | `/api/medicine-providers` | Public | List registered medicine providers |
| `POST` | `/api/medicine-orders` | Private | Place medicine order (requires prescription for Rx items) |
| `GET` | `/api/medicine-orders/my` | Private | Get user's medicine orders |
| `GET` | `/api/medicine-orders/:id` | Private | Get order tracking details |
| `PUT` | `/api/medicine-orders/:id` | Private (Provider/Admin)| Update delivery status |

---

### 11. Adoption Registry (`/api/adoption`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/adoption/animals` | Private (Shelter Only) | List animal for adoption |
| `GET` | `/api/adoption/animals` | Public | Browse animals for adoption |
| `GET` | `/api/adoption/animals/:id` | Public | Get adoption animal profile |
| `PUT` | `/api/adoption/animals/:id` | Private (Shelter Only) | Update adoption animal status |
| `POST` | `/api/adoption/applications` | Private | Submit application to adopt an animal |
| `GET` | `/api/adoption/applications/my` | Private | View my adoption applications |
| `PUT` | `/api/adoption/applications/:id` | Private (Shelter Only) | Review adoption application |

---

### 12. Notifications (`/api/notifications`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `GET` | `/api/notifications` | Private | Get in-app notifications |
| `PUT` | `/api/notifications/:id/read` | Private | Mark single notification as read |
| `PUT` | `/api/notifications/read-all` | Private | Mark all notifications as read |

---

### 13. Admin Management (`/api/admin`)
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `GET` | `/api/admin/facilities/pending` | Private (Admin) | List facilities awaiting verification |
| `PUT` | `/api/admin/facilities/:id/verify` | Private (Admin) | Verify, reject or suspend a facility |
| `GET` | `/api/admin/stats` | Private (Admin) | Platform dashboard statistics |
| `GET` | `/api/admin/audit-logs` | Private (Admin) | Security and administration audit logs |
| `PUT` | `/api/admin/users/:id/status` | Private (Admin) | Suspend or reactivate user account |
| `GET` | `/api/admin/photo-verification/:caseId` | Private (Admin) | View volunteer vs hospital photos |
| `PUT` | `/api/admin/photo-verification/:caseId` | Private (Admin) | Record photo matching decision |

---

## 🔐 Authentication & Role-Based Access Control (RBAC)

### JWT Usage
When logging in or registering, the API returns a JWT token. Send this token in the `Authorization` header on all protected endpoints:
```
Authorization: Bearer <your_jwt_token>
```

### Roles Supported
- `volunteer` (Public User / Citizen)
- `hospital` (Veterinary Hospital)
- `clinic` (Veterinary Clinic)
- `shelter` (Animal Shelter)
- `pet_care_provider` (Pet Boarding / Grooming / Foster)
- `medicine_provider` (Pharmacy / Medical Supplier)
- `donor` (Platform Benefactor)
- `admin` (Platform Administrator)

---

## 📷 File & Image Uploads

The backend supports both **local disk storage** and **Cloudinary** via Multer:

1. **Local Mode (Default)**:
   Files are saved to `/uploads` and served statically at:
   ```
   http://localhost:5000/uploads/<filename>
   ```
2. **Cloudinary Mode**:
   Set `STORAGE_TYPE=cloudinary` and add your Cloudinary credentials in `.env`. Files are uploaded to Cloudinary and return full secure HTTPS URLs.

Supported MIME types: `image/jpeg`, `image/png`, `image/webp`, `application/pdf`, `application/msword`.
Max file size: **10 MB**.

---

## 🧪 Testing Guide

The project includes an automated test suite verifying authentication, case management, facility verification permissions, funding security, and prescription validations.

Run all automated tests:
```bash
npm test
```

Expected output:
```
PASS tests/auth.test.js
PASS tests/cases.test.js
PASS tests/facilities.test.js
PASS tests/funding.test.js
PASS tests/medicine.test.js

Test Suites: 5 passed, 5 total
Tests:       18 passed, 18 total
Snapshots:   0 total
Time:        4.5 s
```

---

## 📱 Flutter Integration Guide

### Base URL Configuration
In your Flutter app, configure the base API URL depending on the running environment:

```dart
// lib/config/api_constants.dart
class ApiConstants {
  // For Android Emulator (maps to host localhost)
  static const String androidBaseUrl = 'http://10.0.2.2:5000/api';

  // For iOS Simulator or macOS desktop
  static const String iosBaseUrl = 'http://localhost:5000/api';

  // For Physical Device connected on same Wi-Fi (replace with your PC IP)
  static const String physicalDeviceUrl = 'http://192.168.1.5:5000/api';

  // Active Base URL
  static const String baseUrl = androidBaseUrl;
}
```

### Sample HTTP Service Integration
Using `http` or `dio` in Flutter:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';

class ApiService {
  String? _authToken;

  void setToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // 1. Fetch All Active Cases
  Future<List<dynamic>> getActiveCases() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/cases'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']['items'];
    }
    throw Exception('Failed to load cases');
  }

  // 2. Report Animal Case with Photo Upload
  Future<Map<String, dynamic>> reportCase({
    required String animalType,
    required String condition,
    required String description,
    required String locationAddress,
    String? imageFilePath,
  }) async {
    var uri = Uri.parse('${ApiConstants.baseUrl}/cases');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Authorization': 'Bearer $_authToken'});

    request.fields['animalType'] = animalType;
    request.fields['condition'] = condition;
    request.fields['description'] = description;
    request.fields['locationAddress'] = locationAddress;

    if (imageFilePath != null) {
      request.files.add(await http.MultipartFile.fromPath('images', imageFilePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data']['case'];
    }
    throw Exception('Failed to report case: ${response.body}');
  }
}
```

---

## 🛡 Admin Backend & Security Features

- **Facility Verification Gate**: Facilities cannot mark themselves as verified. Only an admin endpoint (`PUT /api/admin/facilities/:id/verify`) can toggle this status.
- **Funding Approval Isolation**: Medical facilities cannot approve their own funding applications. Requests remain `Submitted` until an admin performs verification.
- **Audit Logging**: Every sensitive action (facility verification, funding decision, user suspension, photo review) is logged in the `AuditLog` collection with IP address, user agent, actor ID, and timestamps.
- **Rate Limiting**: Protects against brute-force and DDoS attacks (configured in `.env`).
- **Data Protection**: Sensitive password hashes are automatically stripped from JSON outputs and never returned to clients.

---

## 🌐 Production Deployment Considerations

1. **Database**: Use a managed MongoDB cluster (MongoDB Atlas) with TLS enabled and IP whitelisting.
2. **Environment Variables**: Never commit `.env` into source control. Use your cloud provider's secret manager.
3. **Cloud Storage**: Set `STORAGE_TYPE=cloudinary` and configure AWS S3 / Cloudinary credentials for permanent media hosting.
4. **Process Management**: Run the backend using PM2 or Docker:
   ```bash
   pm2 start src/server.js --name "animal-connect-backend"
   ```
5. **Reverse Proxy & SSL**: Deploy behind NGINX or AWS ALB with HTTPS / Let's Encrypt certificates.
