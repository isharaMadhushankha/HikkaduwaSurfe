import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/user/user_main_screen.dart';
import '../screens/user/instructor_detail_screen.dart';
import '../screens/user/booking_form_screen.dart';
import '../screens/user/booking_confirm_screen.dart';
import '../screens/user/booking_detail_screen.dart';
import '../screens/user/write_review_screen.dart';
import '../screens/instructor/instructor_main_screen.dart';
import '../screens/instructor/instr_booking_detail_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isAuthRoute = state.matchedLocation == '/' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password';

        if (!isLoggedIn && !isAuthRoute) return '/';
        if (isLoggedIn && isAuthRoute) {
          return authProvider.isInstructor
              ? '/instructor'
              : '/user';
        }
        return null;
      },
      routes: [
        // ---- Auth Routes ----
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // ---- User Routes ----
        GoRoute(
          path: '/user',
          builder: (context, state) => const UserMainScreen(),
          routes: [
            GoRoute(
              path: 'instructor/:id',
              builder: (context, state) => InstructorDetailScreen(
                instructorId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'book/:instructorId',
              builder: (context, state) => BookingFormScreen(
                instructorId: state.pathParameters['instructorId']!,
              ),
            ),
            GoRoute(
              path: 'booking-confirm',
              builder: (context, state) => BookingConfirmScreen(
                bookingData: state.extra as Map<String, dynamic>,
              ),
            ),
            GoRoute(
              path: 'booking/:id',
              builder: (context, state) => BookingDetailScreen(
                bookingId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'review/:bookingId',
              builder: (context, state) => WriteReviewScreen(
                bookingId: state.pathParameters['bookingId']!,
              ),
            ),
          ],
        ),

        // ---- Instructor Routes ----
        GoRoute(
          path: '/instructor',
          builder: (context, state) => const InstructorMainScreen(),
          routes: [
            GoRoute(
              path: 'booking/:id',
              builder: (context, state) => InstrBookingDetailScreen(
                bookingId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
