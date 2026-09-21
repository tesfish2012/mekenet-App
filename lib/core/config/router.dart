import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/otp_page.dart';
import '../../features/authentication/presentation/pages/pin_login_page.dart';
import '../../features/authentication/presentation/pages/create_pin_page.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/broker/presentation/pages/broker_agreements_page.dart';
import '../../features/broker/presentation/pages/broker_claims_page.dart';
import '../../features/broker/presentation/pages/broker_clients_page.dart';
import '../../features/broker/presentation/pages/broker_dashboard_page.dart';
import '../../features/broker/presentation/pages/broker_documents_page.dart';
import '../../features/broker/presentation/pages/broker_endorsements_page.dart';
import '../../features/broker/presentation/pages/broker_policies_page.dart';
import '../../features/broker/presentation/pages/broker_profile_page.dart';
import '../../features/claims/presentation/pages/claims_page.dart';
import '../../features/claims/presentation/pages/claim_detail_page.dart';
import '../../features/claims/presentation/pages/new_claim_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/payments/presentation/pages/payment_detail_page.dart';
import '../../features/policies/presentation/pages/policies_page.dart';
import '../../features/policies/presentation/pages/policy_detail_page.dart';
import '../../features/policies/presentation/pages/browse_policy_detail_page.dart';
import '../../features/policies/presentation/pages/apply_policy_page.dart';
import '../../features/policies/presentation/pages/browse_policies_page.dart';
import '../../features/policies/presentation/pages/digital_card_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/support/presentation/pages/faq_page.dart';
import '../../shared/pages/splash_page.dart';
import '../../shared/pages/not_found_page.dart';
import '../../shared/pages/about_page.dart';
import '../../shared/pages/privacy_policy_page.dart';
import '../../shared/pages/terms_page.dart';
import '../../shared/widgets/app_shell.dart';
import '../constants/app_constants.dart';

// ── Shell navigation keys ─────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Listenable that only triggers when auth status flips between logged in / out,
/// preventing the entire GoRouter and widget tree from being destroyed on loading state.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Ref ref) {
    ref.listen<bool>(
      authNotifierProvider.select((s) => s.isAuthenticated),
      (prev, next) {
        if (prev != next) {
          notifyListeners();
        }
      },
    );
  }
}

/// Router provider - manually defined (no code generation needed)
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = AuthRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.routeSplash,
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => const NotFoundPage(),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthenticated = ref.read(authNotifierProvider).isAuthenticated;

      // Let splash handle its own navigation
      if (location == AppConstants.routeSplash) return null;

      // Public routes — accessible without auth
      final publicRoutes = [
        AppConstants.routeOnboarding,
        AppConstants.routeLogin,
        AppConstants.routeRegister,
        AppConstants.routeBrokerRegister,
        AppConstants.routeForgotPassword,
        AppConstants.routeOtp,
        AppConstants.routePinLogin,
      ];
      final isPublic = publicRoutes.any((r) => location.startsWith(r));

      if (!isAuthenticated && !isPublic) {
        return AppConstants.routeLogin;
      }

      if (isAuthenticated && (location == AppConstants.routeLogin ||
          location == AppConstants.routeOnboarding ||
          location == '/register')) {
        return AppConstants.routeDashboard;
      }

      return null;
    },
    routes: [
      // ── Splash ───────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeSplash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // ── Onboarding ───────────────────────────────────────
      GoRoute(
        path: AppConstants.routeOnboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // ── Auth ─────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        name: 'register',
        pageBuilder: (context, state) {
          final isBroker = state.uri.queryParameters['role'] == 'broker';
          return _slideTransition(
            state: state,
            child: RegisterPage(initialIsBroker: isBroker),
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeBrokerRegister,
        name: 'broker-register',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const RegisterPage(initialIsBroker: true),
        ),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppConstants.routeOtp,
        name: 'otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpPage(email: email);
        },
      ),
      GoRoute(
        path: AppConstants.routeCreatePin,
        name: 'create-pin',
        builder: (context, state) => const CreatePinPage(),
      ),
      GoRoute(
        path: AppConstants.routePinLogin,
        name: 'pin-login',
        builder: (context, state) => const PinLoginPage(),
      ),

      // ── App Shell (bottom nav) ────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppConstants.routeDashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.routePolicies,
            name: 'policies',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const PoliciesPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeClaims,
            name: 'claims',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const ClaimsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.routePayments,
            name: 'payments',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const PaymentsPage(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeProfile,
            name: 'profile',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const ProfilePage(),
            ),
          ),

          // ── Broker Portal (inside shell for bottom nav) ──
          GoRoute(
            path: kBrokerDashRoute,
            name: 'broker-dashboard',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const BrokerDashboardPage(),
            ),
          ),
          GoRoute(
            path: kBrokerClientsRoute,
            name: 'broker-clients',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const BrokerClientsPage(),
            ),
          ),
          GoRoute(
            path: kBrokerPoliciesRoute,
            name: 'broker-policies',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const BrokerPoliciesPage(),
            ),
          ),
          GoRoute(
            path: kBrokerClaimsRoute,
            name: 'broker-claims',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const BrokerClaimsPage(),
            ),
          ),
          GoRoute(
            path: kBrokerProfileRoute,
            name: 'broker-profile',
            pageBuilder: (context, state) => _noTransition(
              state: state,
              child: const BrokerProfilePage(),
            ),
          ),
        ],
      ),

      // ── Full-screen routes (outside shell) ───────────────
      GoRoute(
        path: '/policies/browse',
        name: 'browse-policies',
        builder: (context, state) => const BrowsePoliciesPage(),
      ),
      GoRoute(
        path: '/policies/browse/:id',
        name: 'browse-policy-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return BrowsePolicyDetailPage(policyId: id);
        },
      ),
      GoRoute(
        path: '/policies/apply/:id',
        name: 'apply-policy',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final pricingIndex = int.tryParse(
                state.uri.queryParameters['pricingIndex'] ?? '');
          return ApplyPolicyPage(
            policyId: id,
            selectedPricingIndex: pricingIndex,
          );
        },
      ),
      GoRoute(
        path: '/policies/:id',
        name: 'policy-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PolicyDetailPage(policyId: id);
        },
      ),
      GoRoute(
        path: '/policies/:id/card',
        name: 'digital-card',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return DigitalCardPage(insuranceId: id);
        },
      ),
      GoRoute(
        path: '/claims/new',
        name: 'new-claim',
        builder: (context, state) {
          final insuranceId = state.uri.queryParameters['insuranceId'];
          return NewClaimPage(
            insuranceId: insuranceId != null ? int.tryParse(insuranceId) : null,
          );
        },
      ),
      GoRoute(
        path: '/claims/:id',
        name: 'claim-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ClaimDetailPage(claimId: id);
        },
      ),
      GoRoute(
        path: '/payments/:id',
        name: 'payment-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PaymentDetailPage(paymentId: id);
        },
      ),
      GoRoute(
        path: AppConstants.routeDocuments,
        name: 'documents',
        builder: (context, state) => const DocumentsPage(),
      ),
      GoRoute(
        path: AppConstants.routeNotifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppConstants.routeEditProfile,
        name: 'edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppConstants.routeSupport,
        name: 'support',
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: AppConstants.routeFaq,
        name: 'faq',
        builder: (context, state) => const FaqPage(),
      ),
      GoRoute(
        path: AppConstants.routeAbout,
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppConstants.routePrivacyPolicy,
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppConstants.routeTerms,
        name: 'terms',
        builder: (context, state) => const TermsPage(),
      ),

      // ── Broker Portal – full-screen sub-pages (outside shell) ──
      GoRoute(
        path: kBrokerAgreementsRoute,
        name: 'broker-agreements',
        builder: (context, state) => const BrokerAgreementsPage(),
      ),
      GoRoute(
        path: kBrokerEndorsementsRoute,
        name: 'broker-endorsements',
        builder: (context, state) => const BrokerEndorsementsPage(),
      ),
      GoRoute(
        path: kBrokerDocumentsRoute,
        name: 'broker-documents',
        builder: (context, state) => const BrokerDocumentsPage(),
      ),

      GoRoute(
        path: AppConstants.routeNotFound,
        name: 'not-found',
        builder: (context, state) => const NotFoundPage(),
      ),
    ],
  );
});

// ── Page transition helpers ───────────────────────────────

CustomTransitionPage<T> _fadeTransition<T>({
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
      transitionDuration:
          const Duration(milliseconds: AppConstants.pageTransitionDuration),
    );

CustomTransitionPage<T> _slideTransition<T>({
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, c) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: c,
      ),
      transitionDuration:
          const Duration(milliseconds: AppConstants.pageTransitionDuration),
    );

NoTransitionPage<T> _noTransition<T>({
  required GoRouterState state,
  required Widget child,
}) =>
    NoTransitionPage<T>(key: state.pageKey, child: child);
