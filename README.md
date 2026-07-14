<div align="center">
  <img src="https://via.placeholder.com/150/D32F2F/FFFFFF?text=RED+BANK" alt="Red Bank Logo" width="150" />

  # Red Bank
  
  **Emergency Medical Logistics Platform**

  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Spring Boot](https://img.shields.io/badge/Spring_Boot-F2F4F9?style=for-the-badge&logo=spring-boot)](https://spring.io/projects/spring-boot)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

  *Saving lives through deterministic spatial matching and instant notifications.*
</div>

---

## 📖 Table of Contents
1. [Vision & Problem Statement](#-vision--problem-statement)
2. [Solution Overview](#-solution-overview)
3. [Features](#-features)
4. [Technology Stack](#-technology-stack)
5. [High-Level Architecture](#-high-level-architecture)
6. [Project Structure](#-project-structure)
7. [Screenshots](#-screenshots)
8. [Installation & Setup](#-installation--setup)
9. [Documentation Index](#-documentation-index)
10. [Roadmap](#-roadmap)
11. [Contributing](#-contributing)
12. [License & Contact](#-license--contact)

---

## 🎯 Vision & Problem Statement

### The Vision  

To reduce the average time required to locate and dispatch an eligible blood donor during a critical medical emergency from hours to **under 15 minutes**.

### The Problem
During a medical crisis, searching for blood relies heavily on unverified, chaotic WhatsApp forwards and social media posts. This leads to dangerous delays, severe privacy violations for patients, donor fatigue, and high failure rates in critical moments.

---

## 💡 Solution Overview
**Red Bank** replaces the chaos of social media with a **highly deterministic, spatial-matching logistics engine**. When an emergency request is triggered, the system instantly cross-references donor biological compatibility, real-time geographical distance via PostGIS, trust scores, and recent donation history to autonomously ping the closest, most reliable donors.

---

## ⭐ Features

### MVP Features (V1)
- **Spatial Matching Engine**: Instant  location-based radius queries using `ST_DWithin`.
- **Intelligent Escalation**: Automated radius expansion (5km → 10km → 15km) if requests are not accepted.
- **Strict Verification**: Four-tier trust system ensuring donor reliability and minimizing fake requests.
- **Privacy by Design**: Patient data is masked. Phone numbers are hidden until a donor accepts the request.
- **Instant Push Notifications**: Deep-linked Firebase Cloud Messaging alerts bypassing SMS delays.
- **Admin Oversight Dashboard**: Centralized management for KYC document verification.

### Future Features (V2)
- **AI Predictive Matching**: Machine learning models to predict the probability of donor acceptance.
- **Hospital B2B Portal**: Webhooks integrating directly into hospital inventory systems.
- **Volunteer Organization Management**: Leaderboards and analytics for NGOs running donor drives.

---

## 🛠 Technology Stack

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Cross-platform Mobile UI (iOS/Android) |
| **Backend** | Java 21, Spring Boot 3 | Stateless REST API, Matching Engine |
| **Database** | PostgreSQL + PostGIS | Relational data & geospatial calculations |
| **Authentication** | Firebase Auth | Phone-based OTP & JWT generation |
| **Notifications** | Firebase Cloud Messaging (FCM) | Reliable push notifications |
| **Storage** | Cloudinary | Secure KYC ID & profile image storage |
| **Mapping** | Google Maps Platform | Map rendering & distance visualization |

---

## 🏗 High-Level Architecture
Red Bank utilizes a **Modular Monolith** architecture for V1. It is designed to scale horizontally across PaaS instances while maintaining clear domain boundaries (Auth, Donor, Request, Matching) to allow seamless extraction into microservices for V2.

```text
[ iOS / Android Apps ] <--> [ Load Balancer ] <--> [ Spring Boot Instances ] <--> [ PostGIS Database ]
                                                         |
                                                         +--> [ Firebase Auth / FCM ]
                                                         +--> [ Cloudinary CDN ]
```

---

## 📂 Project Structure

```text
red-bank-v2/
├── backend/                  # Java Spring Boot 3 Application
│   ├── src/main/java/...     # Core domain modules (auth, core, donor, etc.)
│   ├── src/main/resources/   # YAML configs & Flyway SQL migrations
│   └── pom.xml               # Maven dependencies
├── frontend/                 # Flutter Mobile Application
│   ├── lib/                  # Dart source code (Riverpod state, GoRouter)
│   ├── assets/               # Local app assets
│   └── pubspec.yaml          # Flutter dependencies
├── docs/                     # Approved Architectural Specifications
├── docker-compose.yml        # Local infrastructure definition
└── README.md                 # This file
```

---

## 📱 Screenshots

<div align="center">
  <i>(UI Implementation in progress. Screenshots will be added post-Beta release.)</i><br/><br/>
  
  <img src="https://via.placeholder.com/250x500.png?text=Splash+Screen" width="200"/>
  <img src="https://via.placeholder.com/250x500.png?text=Emergency+Request" width="200"/>
  <img src="https://via.placeholder.com/250x500.png?text=Live+Map+Tracking" width="200"/>
</div>

---

## 🚀 Installation & Setup

### Prerequisites
- [JDK 21](https://adoptium.net/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable branch)
- [Docker & Docker Compose](https://www.docker.com/)
- [Maven](https://maven.apache.org/)

### 1. Running PostgreSQL (Database)
The backend requires a PostGIS-enabled PostgreSQL database. Spin up a local container:
```bash
docker-compose up -d
```
*This exposes PostgreSQL on `localhost:5432` with user `redbank_user`.*

### 2. Development Setup (Environment Variables)
Create a `.env` file or export the following variables before running the backend:
```bash
export DB_URL=jdbc:postgresql://localhost:5432/redbank_dev
export DB_USERNAME=redbank_user
export DB_PASSWORD=redbank_password
export FIREBASE_CREDENTIALS=classpath:firebase-dev.json
export CLOUDINARY_URL=cloudinary://<API_KEY>:<API_SECRET>@<CLOUD_NAME>
```

### 3. Running Backend (Spring Boot)
Flyway migrations will automatically execute on startup.
```bash
cd backend
mvn clean install -DskipTests
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```
*API available at: `http://localhost:8080/api/v1/`*

### 4. Running Frontend (Flutter)
Ensure a simulator is running or a device is connected.
```bash
cd frontend
flutter pub get
flutter run
```

---

## 📚 Documentation Index
The platform was architected prior to development. All engineering strictly adheres to these living documents.

| Document | Description |
| :--- | :--- |
| **`00_Vision.md`** | Core mission, problem statement, and MVP scope. |
| **`02_BusinessRulesSpecification.md`** | Governing logic for eligibility, scoring, and trust vectors. |
| **`03_SystemArchitecture.md`** | High-level system design and component interaction. |
| **`04_DatabaseDesign.md`** | Relational schema, normalizations, and PostGIS usage. |
| **`05_DRD.md`** | Developer Requirements Document & coding standards. |
| **`06_APIDocumentation.md`** | REST API contracts and endpoints. |
| **`07_UI_UX_Specification.md`** | Interface design philosophy and user flows. |
| **`08_BackendSpecification.md`** | Spring Boot modular implementation guidelines. |
| **`09_MatchingEngine.md`** | The deterministic spatial/biological heuristic algorithm. |
| **`10_SecurityGuidelines.md`** | Operational security, privacy, and JWT implementation. |
| **`11_TestingStrategy.md`** | Quality assurance metrics and CI/CD testing pyramid. |
| **`12_DeploymentGuide.md`** | Cloud infrastructure and disaster recovery protocols. |
| **`13_DevelopmentRoadmap.md`** | Phase-by-phase execution plan and sprint planning. |
| **`14_RiskRegister.md`** | Enterprise risk management and contingency planning. |

---

## 🛣 Roadmap
We have successfully executed **Phase 3 (Donor Module)** of the `13_DevelopmentRoadmap.md`. We are now transitioning into **Phase 4 (Emergency Module)**.
For a detailed view of upcoming sprints, milestones (Alpha, Beta, RC1), and the transition into V2 Enterprise features, please review the Development Roadmap document.

---

## 🤝 Contributing
We welcome contributions from the community to help save lives! 
1. Read the `05_DRD.md` to understand our clean architecture and coding standards.
2. Fork the repository and create a feature branch (`git checkout -b feat/your-feature`).
3. Ensure all tests pass (`mvn test` / `flutter test`).
4. Open a Pull Request referencing the related issue.

---

## 📄 License
Distributed under the **MIT License**. See `LICENSE` for more information.

---

## 💬 Contact
- **Project Link:** [https://github.com/navintomm/RedBank](https://github.com/navintomm/RedBank)
- **Support:** support@redbank.example.com
- **Security:** security@redbank.example.com

<div align="center">
  <i>Built with ❤️ to save lives.</i>
</div>
