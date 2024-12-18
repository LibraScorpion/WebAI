import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme_config.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/auth/secure_storage_service.dart';
import 'state/auth_provider.dart';
import 'state/chat_provider.dart';
import 'state/settings_provider.dart';
import 'views/auth/login_page.dart';
import 'views/auth/biometric_auth_page.dart';
import 'views/home/home_page.dart';
import 'widgets/common_widgets/loading_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authService = AuthService(apiService, prefs);
  
  // Check for stored auth token
  final secureStorage = SecureStorageService();
  final token = await secureStorage.getAuthToken();

  runApp(MyApp(
    apiService: apiService,
    authService: authService,
    initialToken: token,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final AuthService authService;
  final String? initialToken;

  const MyApp({
    super.key,
    required this.apiService,
    required this.authService,
    this.initialToken,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiService),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'WebAI Mobile',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: initialToken != null ? '/biometric' : '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/biometric': (context) => const BiometricAuthPage(),
          '/home': (context) => const HomePage(),
        },
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const LoadingOverlay(
                isLoading: true,
                child: Scaffold(),
              );
            }
            return authProvider.isAuthenticated
                ? const HomePage()
                : const LoginPage();
          },
        ),
      ),
    );
  }
}
