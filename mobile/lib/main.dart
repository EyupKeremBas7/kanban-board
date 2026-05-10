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

  @override
  Widget build(BuildContext context) {
    // Service'leri oluştur
    final authService = AuthService();
    final apiService = ApiService(authService);
    final socketService = SocketService(authService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthViewModel(apiService: apiService, authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => BoardsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ListsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CardsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChecklistsViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityViewModel(apiService: apiService),
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
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider.value(value: socketService),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsVM, child) {
          return MaterialApp(
            title: 'Kanban Board',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: settingsVM.themeMode,
            locale: settingsVM.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', ''),
              Locale('en', ''),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
