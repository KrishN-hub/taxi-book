import 'package:get/get.dart';

import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/signup_page.dart';
import '../../features/driver_home/views/driver_home_page.dart';
import '../../features/passenger_home/views/passenger_home_page.dart';
import '../../features/profile/views/profile_page.dart';
import '../../features/ride_history/views/ride_history_page.dart';
import '../../features/ride_request/views/ride_request_page.dart';
import '../../features/splash/views/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: SplashPage.new),
    GetPage(name: AppRoutes.login, page: LoginPage.new),
    GetPage(name: AppRoutes.signup, page: SignupPage.new),
    GetPage(name: AppRoutes.passengerHome, page: PassengerHomePage.new),
    GetPage(name: AppRoutes.driverHome, page: DriverHomePage.new),
    GetPage(name: AppRoutes.rideRequest, page: RideRequestPage.new),
    GetPage(name: AppRoutes.rideHistory, page: RideHistoryPage.new),
    GetPage(name: AppRoutes.profile, page: ProfilePage.new),
  ];
}
