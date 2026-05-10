import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/screens/boards.dart';
import 'package:mobile/screens/inbox.dart';
import 'package:mobile/screens/planner.dart';
import 'package:mobile/screens/activity.dart';
import 'package:mobile/screens/account.dart';
import 'package:mobile/viewmodels/notifications_viewmodel.dart';
import 'package:mobile/viewmodels/navigation_viewmodel.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// 5-sekmeli BottomNavigationBar wrapper.
/// Sekmeler: Panolar, Gelen Kutusu, Ana Sayfa, Etkinlik, Hesap
/// IndexedStack ile sayfaların state'i korunur.
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  final List<Widget> _screens = const [
    BoardsScreen(),
    InboxScreen(),
    PlannerScreen(),
    ActivityScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<NotificationsViewModel>().fetchUnreadCount();
      }
    });
  }

  Widget _buildInboxIcon(int unreadCount, bool selected) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(selected ? Icons.inbox : Icons.inbox_outlined),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final navVM = context.watch<NavigationViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Consumer<NotificationsViewModel>(
      builder: (context, notificationsVM, child) {
        return Scaffold(
          body: IndexedStack(index: navVM.currentIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navVM.currentIndex,
            onDestinationSelected: (index) {
              navVM.setIndex(index);
              if (index != 0) {
                navVM.clearWorkspaceFilter();
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l10n.boards,
              ),
              NavigationDestination(
                icon: _buildInboxIcon(
                  notificationsVM.unreadCount,
                  navVM.currentIndex == 1,
                ),
                selectedIcon: _buildInboxIcon(
                  notificationsVM.unreadCount,
                  true,
                ),
                label: l10n.inbox,
              ),
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.appTitle, // Using appTitle as "Ana Sayfa" placeholder
              ),
              NavigationDestination(
                icon: const Icon(Icons.notifications_outlined),
                selectedIcon: const Icon(Icons.notifications),
                label: l10n.activity,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outlined),
                selectedIcon: const Icon(Icons.person),
                label: l10n.account,
              ),
            ],
          ),
        );
      },
    );
  }
}

