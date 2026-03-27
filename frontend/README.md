# Snail Taxi App - Flutter Frontend (Steps 1-3)

This implementation includes:
- Full frontend folder structure (PRD-aligned)
- Splash page
- Login page
- Signup page
- Firebase Auth integration
- GetX routing + controller setup
- Reusable custom widgets (`CustomButton`, `CustomTextField`)
- Passenger map screen using `flutter_map` + OpenStreetMap
- Ride request flow wiring
- Driver home receiving and accepting requests via Socket.IO
- Passenger real-time driver tracking listener
- Ride history page
- Sandbox payment trigger buttons (Stripe/Razorpay API calls)

## Folder Structure

```text
frontend/
  pubspec.yaml
  lib/
    main.dart
    firebase_options.dart
    app/
      app.dart
      config/
        app_config.dart
      routes/
        app_pages.dart
        app_routes.dart
      theme/
        app_theme.dart
    data/
      models/
        ride_model.dart
      services/
        auth_service.dart
        backend_auth_service.dart
        session_service.dart
        api_client.dart
        ride_service.dart
        payment_service.dart
        socket_service.dart
    features/
      splash/views/splash_page.dart
      auth/
        controllers/auth_controller.dart
        views/login_page.dart
        views/signup_page.dart
      passenger_home/
        controllers/passenger_home_controller.dart
        views/passenger_home_page.dart
      driver_home/
        controllers/driver_home_controller.dart
        views/driver_home_page.dart
      ride_request/
        controllers/ride_request_controller.dart
        views/ride_request_page.dart
      ride_history/
        controllers/ride_history_controller.dart
        views/ride_history_page.dart
      profile/views/profile_page.dart
    shared/
      widgets/
        custom_button.dart
        custom_text_field.dart
```

## Setup Instructions (Ready to paste)

1. Create app:
   ```bash
   flutter create frontend
   ```
2. Replace generated `frontend/lib` and `frontend/pubspec.yaml` with these files.
3. Install packages:
   ```bash
   cd frontend
   flutter pub get
   ```
4. Configure Firebase:
   - Create Firebase project
   - Enable **Email/Password** in Firebase Auth
   - Run:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
   - This generates real values for `lib/firebase_options.dart`.
5. Run app:
   ```bash
   flutter run
   ```

## Notes

- `app_config.dart` uses `10.0.2.2` for Android emulator backend access.
- Replace base URLs with your machine LAN IP for real devices.
- Payment buttons currently run sandbox API flow (create + confirm).
