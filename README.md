# Password Manager

A cross-platform Flutter app for securely storing, managing, and backing up user credentials. The app prioritizes security, usability, and offline access.

## Features

- Store, edit, delete, and view login credentials
- Local encrypted storage (AES-256)
- Authentication via PIN and biometrics
- Searchable credential list
- Copy username/password to clipboard
- Responsive UI for phones and tablets
- Offline support (no cloud sync)

## Technical Stack

- **Platform:** Flutter (Dart)
- **Database:** SQFLite (with SQLCipher for encryption)
- **Encryption:** AES-256
- **Authentication:** Local PIN and biometrics
- **Recommended Libraries:**
  - flutter_secure_storage
  - sqflite_sqlcipher
  - encrypt
  - local_auth
  - path
  - shared_preferences
  - clipboard

## Data Model

- Credential: id, website/app name, username, password, notes, created_at, updated_at
- PIN: Securely stored hash

## Requirements

- Fast load and search for up to 1000 credentials
- Minimal steps for common actions
- No transmission of credentials outside device
- Use platform secure storage for PIN and encryption keys
- Error and success feedback for all actions
- Lockout after repeated failed authentication attempts

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.
