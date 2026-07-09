# Red Bank - Authentication Module

## Overview
This module handles all identity and session management for the Red Bank platform using Firebase Phone Authentication and custom Spring Security JWTs.

## Flow Diagram
1. Flutter App requests OTP via Firebase Auth.
2. User submits OTP to Firebase.
3. Firebase returns an `id_token`.
4. Flutter App calls `POST /api/v1/auth/verify` with `id_token`.
5. Spring Boot `AuthService` verifies `id_token` cryptographically using Firebase Admin SDK.
6. Spring Boot queries PostgreSQL. If User doesn't exist, provisions a new record with `ROLE_DONOR`.
7. Spring Boot issues a custom JWT (`access_token`) and a `refresh_token`.
8. Flutter stores tokens securely and updates `AuthState`.

## Packages
- **`com.redbank.auth.security`**: Core JWT signing and stateless validation filters.
- **`com.redbank.auth.service`**: Business logic handling DB inserts and token generation.
- **`com.redbank.auth.controller`**: Exposed REST endpoints.
