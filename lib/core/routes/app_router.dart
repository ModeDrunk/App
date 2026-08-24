import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/screens/pin_screen.dart';
import '../../features/drunk-mode/presentation/screens/active_mode_screen.dart';
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/contacts/presentation/screens/add_edit_contact_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/change_pin_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String pin = '/pin';
  static const String activeMode = '/active-mode';
  static const String contacts = '/contacts';
  static const String addContact = '/add-contact';
  static const String editContact = '/edit-contact/:id';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String changePin = '/change-pin';
}

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      routes: [
        // Onboarding
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Home
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Drunk Mode
        GoRoute(
          path: AppRoutes.pin,
          name: 'pin',
          builder: (context, state) => const PinScreen(),
        ),
        GoRoute(
          path: AppRoutes.activeMode,
          name: 'active-mode',
          builder: (context, state) => const ActiveModeScreen(),
        ),

        // Contacts
        GoRoute(
          path: AppRoutes.contacts,
          name: 'contacts',
          builder: (context, state) => const ContactsScreen(),
        ),
        GoRoute(
          path: AppRoutes.addContact,
          name: 'add-contact',
          builder: (context, state) => const AddEditContactScreen(),
        ),
        GoRoute(
          path: AppRoutes.editContact,
          name: 'edit-contact',
          builder: (context, state) {
            final contact = state.extra as Map<String, dynamic>?;
            return AddEditContactScreen(contact: contact);
          },
        ),

        // History
        GoRoute(
          path: AppRoutes.history,
          name: 'history',
          builder: (context, state) => const HistoryScreen(),
        ),

        // Profile
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.changePin,
          name: 'change-pin',
          builder: (context, state) => const ChangePinScreen(),
        ),
      ],
    );
  }
}
