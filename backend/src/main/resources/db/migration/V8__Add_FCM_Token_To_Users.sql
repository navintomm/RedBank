-- Flyway Migration V8: Add FCM Token to Users
-- Adds fcm_token column which was introduced in the User entity for Push Notifications

ALTER TABLE users
ADD COLUMN fcm_token VARCHAR(255);
