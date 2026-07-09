# Security Policy

Red Bank is an emergency medical logistics platform. We handle highly sensitive location data, biological information (blood types), and personal identifiable information (PII). **Security and Privacy are our highest priorities.**

This document outlines our security policies, supported versions, and the process for responsibly disclosing vulnerabilities.

---

## 🛡 Supported Versions

We only provide security updates for the current major release of the platform. If you are deploying an older version of the Red Bank backend, please upgrade to the latest stable release.

| Version | Supported          | Notes |
| ------- | ------------------ | ----- |
| 1.x.x   | :white_check_mark: | Active MVP |
| 0.x.x   | :x:                | Alpha/Beta (Unsupported) |

---

## 🚨 Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a vulnerability in Red Bank, we ask that you practice **Responsible Disclosure**:

1. Email your findings to **[security@redbank.example.com]**.
2. Include a detailed description of the vulnerability, steps to reproduce it, and any potential impact.
3. Allow us a reasonable amount of time (typically 72 hours) to respond to the report before making any information public.
4. We will acknowledge your email, verify the vulnerability, and work with you on a timeline for releasing a patch.

---

## 🔒 Security Best Practices

Contributors and operators of the Red Bank platform must adhere to the following security architectures:

### 1. JWT Security
- **Stateless Authentication**: The Spring Boot backend uses stateless JSON Web Tokens (JWTs). Sessions are never stored in memory.
- **Short Expiry**: Access tokens (`access_token`) are cryptographically signed using `HMAC-SHA256` and expire strictly after **1 hour**.
- **Rotation**: Refresh tokens are stored securely in the PostgreSQL database and are used to issue new access tokens. Refresh tokens expire after 24 hours and are instantly revoked upon explicit logout.

### 2. Firebase Security
- **Verification**: We rely on Firebase Phone Authentication to verify user identities. The Flutter app receives an `id_token` which is then sent to the backend.
- **Admin SDK**: The backend cryptographically verifies the `id_token` against Google's public keys using the Firebase Admin SDK before issuing our internal JWT.
- **Credentials**: The `service-account.json` key must **never** be committed to the repository. It is injected into the CI/CD pipeline exclusively via GitHub Secrets.

### 3. Database Security (PostgreSQL)
- **Parameterized Queries**: All database interactions utilize Spring Data JPA repositories. We strictly prohibit the execution of raw, concatenated SQL strings to prevent SQL Injection.
- **Data Masking**: PII (Phone Numbers) is masked in DTOs. A requester will only see a donor's phone number *after* the donor explicitly accepts the emergency request.
- **Least Privilege**: The database user (`redbank_user`) operates with the minimum privileges required to execute CRUD operations and Flyway migrations.

### 4. Dependency Management
- **Automated Scanning**: We utilize Dependabot (or similar tools) to automatically scan `pom.xml` (Maven) and `pubspec.yaml` (Flutter) for known CVEs.
- **Vulnerable Packages**: Any Pull Request introducing a dependency with a known High/Critical vulnerability will be automatically blocked from merging into `main`.

---

## 📞 Contact

For any questions regarding this policy or general security inquiries, please contact our security team at **[security@redbank.example.com]**.
