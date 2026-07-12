# Red Bank v1.0 Build & Configuration Checklist

Before running the application locally, you must ensure that all configurations and integrations are properly set up. Use this checklist to verify your environment.

## 1. Backend Configuration (Spring Boot)

### 1.1. PostgreSQL Database
- [ ] Install PostgreSQL and PostGIS extensions.
- [ ] Create a local database named `redbank_dev`.
- [ ] Ensure user `redbank_user` with password `redbank_password` has access to `redbank_dev`.
- [ ] Verify that the database is running on `localhost:5432` (or update `DB_URL` in your backend `.env`).

### 1.2. Environment Variables
- [ ] Copy `backend/.env.example` to `backend/.env` (if supported by your launch configuration) or configure your IDE to pass these environment variables:
  - `DB_URL`
  - `DB_USER`
  - `DB_PASSWORD`
  - `CLOUDINARY_URL`

### 1.3. Cloudinary Integration
- [ ] Obtain a Cloudinary URL (format: `cloudinary://API_KEY:API_SECRET@CLOUD_NAME`).
- [ ] Add it to your backend environment variables (`CLOUDINARY_URL`).

### 1.4. Firebase Admin SDK
- [ ] Generate a new private key from your Firebase Project Settings -> Service Accounts.
- [ ] Save the downloaded JSON file as exactly: `backend/src/main/resources/firebase-dev.json`.

---

## 2. Frontend Configuration (Flutter)

### 2.1. Firebase Configuration
- **Android:**
  - [ ] Download `google-services.json` from the Firebase Console.
  - [ ] Place it in `frontend/android/app/google-services.json`.
- **iOS:**
  - [ ] Download `GoogleService-Info.plist` from the Firebase Console.
  - [ ] Place it in `frontend/ios/Runner/GoogleService-Info.plist` using Xcode.

### 2.2. Google Maps API Key
- **Android:**
  - [ ] Open `frontend/android/app/src/main/AndroidManifest.xml`.
  - [ ] Add the following inside the `<application>` tag:
    ```xml
    <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY_HERE"/>
    ```
- **iOS:**
  - [ ] Open `frontend/ios/Runner/AppDelegate.swift`.
  - [ ] Add your API key initialization using `GMSServices.provideAPIKey("YOUR_API_KEY_HERE")`.

### 2.3. Environment Configuration
- [ ] Note that Flutter uses `dart-define` for compile-time environment variables.
- [ ] To connect an Android Emulator to your local Spring Boot instance, use `http://10.0.2.2:8080/api/v1` instead of localhost.
- [ ] Pass the API base URL when running the app:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
  ```

---

## 3. Running the Application

### 3.1. Start the Backend
```bash
cd backend
./mvnw clean spring-boot:run
```
*(Verify that Flyway migrations V1–V5 execute successfully during startup).*

### 3.2. Start the Frontend
```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```
