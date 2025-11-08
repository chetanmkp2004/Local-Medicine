import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_state.dart';
import 'features/common/role_select_page.dart';
import 'features/auth/login_page.dart';
import 'features/search/search_page.dart';
import 'features/shop/dashboard_page.dart';
import 'features/ai/symptom_checker_page.dart';
import 'features/ai/ai_search_page.dart';
import 'features/map/map_view_page.dart';
import 'features/onboarding/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('onboarding_complete') ?? false;
  runApp(ProviderScope(child: MyApp(showOnboarding: !hasSeenOnboarding)));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;

  const MyApp({super.key, this.showOnboarding = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState state = AppState.bootstrap();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: state,
      child: Builder(
        builder: (context) {
          final s = AppStateScope.of(context);
          return MaterialApp(
            title: 'Local Medicine',
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFFF9FAFB),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF007BFF), // Healthcare Trust Blue
                onPrimary: Colors.white,
                primaryContainer: Color(0xFFE3F2FD),
                onPrimaryContainer: Color(0xFF001D35),
                secondary: Color(0xFF4CAF50), // Healthy Green
                onSecondary: Colors.white,
                secondaryContainer: Color(0xFFE8F5E9),
                onSecondaryContainer: Color(0xFF002106),
                tertiary: Color(0xFFFF9800), // Warning Orange
                onTertiary: Colors.white,
                tertiaryContainer: Color(0xFFFFECB3),
                onTertiaryContainer: Color(0xFF2E1500),
                error: Color(0xFFD32F2F),
                onError: Colors.white,
                surface: Color(0xFFF9FAFB),
                onSurface: Color(0xFF1C1B1F),
                surfaceContainerLowest: Colors.white,
                surfaceContainerLow: Color(0xFFF5F5F5),
                surfaceContainer: Color(0xFFEEEEEE),
                surfaceContainerHigh: Color(0xFFE8E8E8),
                surfaceContainerHighest: Color(0xFFE0E0E0),
                onSurfaceVariant: Color(0xFF49454F),
                outline: Color(0xFFCAC4D0),
                outlineVariant: Color(0xFFE0E0E0),
                shadow: Color(0x1A000000),
              ),
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android:
                      PredictiveBackPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
              textTheme: GoogleFonts.notoSansTextTheme()
                  .apply(
                    displayColor: const Color(0xFF1C1B1F),
                    bodyColor: const Color(0xFF1C1B1F),
                  )
                  .copyWith(
                    // Large headings with Poppins for trust and friendliness
                    displayLarge: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    displayMedium: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                    displaySmall: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      height: 1.3,
                    ),
                    headlineLarge: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      height: 1.3,
                    ),
                    headlineMedium: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      height: 1.3,
                    ),
                    headlineSmall: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      height: 1.4,
                    ),
                    // Titles with Poppins
                    titleLarge: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      height: 1.4,
                    ),
                    titleMedium: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                      height: 1.4,
                    ),
                    titleSmall: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                    // Body text with Noto Sans for readability
                    bodyLarge: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      height: 1.5,
                    ),
                    bodyMedium: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25,
                      height: 1.5,
                    ),
                    bodySmall: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.4,
                      height: 1.5,
                    ),
                    // Labels with Poppins for buttons
                    labelLarge: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                    labelMedium: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                    labelSmall: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  ),
              appBarTheme: AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 2,
                backgroundColor: const Color(0xFF007BFF), // Trust Blue
                surfaceTintColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                toolbarHeight: 64,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                surfaceTintColor: const Color(0xFF007BFF),
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                shadowColor: Colors.black.withValues(alpha: 0.1),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  elevation: 2,
                  minimumSize: const Size(48, 48), // Min 48x48dp touch target
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  minimumSize: const Size(48, 48), // Min 48x48dp touch target
                  shadowColor: Colors.black.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size(48, 48), // Min 48x48dp touch target
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF007BFF), width: 2),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical:
                      18, // Larger vertical padding for easier interaction
                ),
                hintStyle: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
                labelStyle: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
                errorStyle: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: const Color(0xFFEF4444),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2, // Thicker borders for better visibility
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF007BFF), // Trust Blue focus
                    width: 2.5, // Prominent focus indicator
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444), // High contrast error red
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2.5,
                  ),
                ),
              ),
              iconButtonTheme: IconButtonThemeData(
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48), // Min 48x48dp touch target
                  iconSize: 24,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: const Color(0xFF007BFF), // Trust Blue
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                iconSize: 28,
                sizeConstraints: const BoxConstraints.tightFor(
                  width: 56,
                  height: 56, // Minimum 56x56 for FAB
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: const Color(0xFFE3F2FD), // Light Trust Blue
                selectedColor: const Color(0xFF007BFF), // Trust Blue
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelStyle: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10, // Larger padding for easier tap
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFFE3F2FD), // Light Trust Blue
                elevation: 3,
                surfaceTintColor: const Color(0xFF007BFF), // Trust Blue
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return GoogleFonts.notoSans(
                    fontSize: 14, // Larger for readability
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.5,
                  );
                }),
                height: 80, // Taller navigation bar for easier touch
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    size: 28, // Larger icons
                    color: isSelected
                        ? const Color(0xFF007BFF)
                        : const Color(0xFF6B7280),
                  );
                }),
              ),
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF1F2937), // Dark gray
                contentTextStyle: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 16, // Larger for readability
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              dividerTheme: const DividerThemeData(
                color: Color(0xFFE5E5E8),
                thickness: 1,
                space: 1,
              ),
              listTileTheme: ListTileThemeData(
                dense: false,
                minLeadingWidth: 24,
                minVerticalPadding: 12, // More vertical padding for easier tap
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                titleTextStyle: GoogleFonts.notoSans(
                  fontSize: 18, // Larger for readability
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  color: const Color(0xFF1F2937),
                ),
                subtitleTextStyle: GoogleFonts.notoSans(
                  fontSize: 16, // Larger for readability
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: widget.showOnboarding ? '/onboarding' : '/',
            onGenerateRoute: (settings) {
              // Custom page transitions
              Widget page;
              switch (settings.name) {
                case '/onboarding':
                  page = const OnboardingPage();
                  break;
                case '/':
                case '/role-select':
                  page = const RoleSelectPage();
                  break;
                case '/login':
                  page = const LoginPage();
                  break;
                case '/search':
                  final arg = settings.arguments;
                  if (arg is String && arg.isNotEmpty) {
                    page = SearchPage(initialQuery: arg);
                  } else {
                    page = const SearchPage();
                  }
                  break;
                case '/dashboard':
                  page = const ShopDashboardPage();
                  break;
                case '/symptom-checker':
                  page = const SymptomCheckerPage();
                  break;
                case '/ai-search':
                  page = const AiSearchPage();
                  break;
                case '/map':
                  page = const MapViewPage();
                  break;
                default:
                  page = const RoleSelectPage();
              }

              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 0.03);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                          .animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeIn,
                            ),
                          );

                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(
                          opacity: fadeAnimation,
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 300),
              );
            },
            locale: Locale(s.languageCode),
          );
        },
      ),
    );
  }
}
