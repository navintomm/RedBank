# Red Bank - Emergency Blood Logistics

Red Bank is an emergency medical logistics platform designed to minimize the time required to locate eligible blood donors. 

## Project Structure
- `/backend`: Java Spring Boot 3.2+ API.
- `/frontend`: Flutter 3.19+ mobile application.
- `/docs`: Approved architectural specifications and guides.

## Local Development Guide

### Prerequisites
- JDK 21
- Flutter SDK (stable)
- Docker Desktop (for PostGIS)
- Maven

### Starting the Database
To run a local PostgreSQL instance with the PostGIS extension enabled:
```bash
docker-compose up -d
```

### Starting the Backend
Navigate to the `backend` directory and run:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```
The Flyway migrations will automatically build the schema on startup.

### Starting the Frontend
Navigate to the `frontend` directory:
```bash
flutter pub get
flutter run
```

### Environment Variables
For local development, copy the `.env.example` (when available) and populate your Firebase JSON keys and Cloudinary URL.
