import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/viewmodels/auth_viewmodel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/viewmodels/boards_viewmodel.dart';
import 'package:mobile/viewmodels/lists_viewmodel.dart';
import 'package:mobile/viewmodels/cards_viewmodel.dart';
import 'package:mobile/viewmodels/comments_viewmodel.dart';
import 'package:mobile/viewmodels/checklists_viewmodel.dart';
import 'package:mobile/viewmodels/activity_viewmodel.dart';
import 'package:mobile/viewmodels/workspaces_viewmodel.dart';
import 'package:mobile/viewmodels/notifications_viewmodel.dart';
import 'package:mobile/viewmodels/invitations_viewmodel.dart';
import 'package:mobile/viewmodels/settings_viewmodel.dart';
import 'package:mobile/viewmodels/navigation_viewmodel.dart';
import 'package:mobile/screens/splash.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Kanban Board — Mobil Uygulama
/// Mimari: MVVM + Provider
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const KanbanBoardApp());
}

class KanbanBoardApp extends StatelessWidget {
  const KanbanBoardApp({super.key});

  ThemeData _buildTheme({
    required Brightness brightness,
    required bool highContrast,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
      contrastLevel: highContrast ? 1.0 : 0.0,
    );
    final isDark = brightness == Brightness.dark;
    final background = highContrast
        ? (isDark ? Colors.black : Colors.white)
        : colorScheme.surface;
    final foreground = highContrast
        ? (isDark ? Colors.white : Colors.black)
        : colorScheme.onSurface;

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      useMaterial3: true,
      dividerTheme: DividerThemeData(
        color: highContrast ? foreground.withValues(alpha: 0.42) : null,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: ThemeData(
        brightness: brightness,
        useMaterial3: true,
      ).textTheme.apply(bodyColor: foreground, displayColor: foreground),
      listTileTheme: ListTileThemeData(
        iconColor: highContrast ? foreground : null,
        textColor: highContrast ? foreground : null,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (!highContrast) return null;
          return states.contains(WidgetState.selected)
              ? colorScheme.primary
              : foreground;
        }),
        trackOutlineColor: WidgetStatePropertyAll(
          highContrast ? foreground : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Service'leri oluştur
    final authService = AuthService();
    final apiService = ApiService(authService);
    final socketService = SocketService(authService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            apiService: apiService,
            authService: authService,
            socketService: socketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BoardsViewModel(
            apiService: apiService,
            socketService: socketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ListsViewModel(
            apiService: apiService,
            socketService: socketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CardsViewModel(
            apiService: apiService,
            socketService: socketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentsViewModel(
            apiService: apiService,
            socketService: socketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChecklistsViewModel(
            apiService: apiService,
            socketService: socketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityViewModel(
            apiService: apiService,
            socketService: socketService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkspacesViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => InvitationsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider.value(value: socketService),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return MaterialApp(
            title: 'Kanban Board',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(
              brightness: Brightness.light,
              highContrast: settingsVM.highContrastEnabled,
            ),
            darkTheme: _buildTheme(
              brightness: Brightness.dark,
              highContrast: settingsVM.highContrastEnabled,
            ),
            themeMode: settingsVM.themeMode,
            locale: settingsVM.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr', ''), Locale('en', '')],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
