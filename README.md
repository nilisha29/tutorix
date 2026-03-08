# Tutorix

Tutorix is a Flutter learning platform app with authentication, tutor discovery,
bookings, messaging, payments, profile management, and sensor-driven interactions.

## Tech Stack

- Flutter (Dart 3)
- Riverpod (state management)
- Dio (networking)
- Hive and SharedPreferences (local storage)
- Flutter Secure Storage
- Sensors Plus (accelerometer)

## Project Structure

The project follows a clean architecture style with feature-first folders:

```
lib/
	app/                 # app bootstrap, routing, theme
	core/                # shared API/config/providers/constants
	features/
		auth/
		dashboard/
		messages/
		payments/
		tutors/
		bookings/
		...
```

Typical feature layout:

```
feature/
	data/
		datasources/
		models/
		repositories/
	domain/
		repositories/
		usecases/
	presentation/
		pages/
		state/
		view_model/
```

## Main Features

- Auth flow: login, register, reset/change password
- Tutor listing and saved tutors
- Booking flow
- Messages inbox and tutor chat
- Payment success flow
- Profile management with dark mode toggle
- Sensors:
	- Accelerometer page
	- Dark mode control page
	- Shake-to-reload in Messages inbox

## Prerequisites

- Flutter SDK installed and available in `PATH`
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter extension
- At least one emulator/device configured

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

## Testing

Run all tests:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

Coverage summary (if configured in your environment):

```bash
flutter pub run test_cov_console
```

## Useful Commands

Format code:

```bash
dart format .
```

Analyze project:

```bash
flutter analyze
```

## Build

Debug APK:

```bash
flutter build apk --debug
```

Release APK:

```bash
flutter build apk --release
```

## Notes

- App display name is configured as `Tutorix` for install labels.
- Launcher icon is generated from `assets/images/on1.png`.

## License

This repository is currently private/internal.
