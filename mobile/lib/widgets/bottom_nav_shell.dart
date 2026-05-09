import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/screens/boards.dart';
import 'package:mobile/screens/inbox.dart';
import 'package:mobile/screens/planner.dart';
import 'package:mobile/screens/activity.dart';
import 'package:mobile/screens/account.dart';
import 'package:mobile/viewmodels/notifications_viewmodel.dart';

/// 5-sekmeli BottomNavigationBar wrapper.
/// Sekmeler: Panolar, Gelen Kutusu, Ana Sayfa, Etkinlik, Hesap
/// IndexedStack ile sekme state korunumu sağlanır (Kural 21).
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  // IndexedStack ile sayfaların state'i korunur
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
      context.read<NotificationsViewModel>().fetchUnreadCount();
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
              decoration: BoxDecoration(
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
    return Consumer<NotificationsViewModel>(
      builder: (context, notificationsVM, child) {
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Panolar',
              ),
              NavigationDestination(
                icon: _buildInboxIcon(
                  notificationsVM.unreadCount,
                  _currentIndex == 1,
                ),
                selectedIcon: _buildInboxIcon(
                  notificationsVM.unreadCount,
                  true,
                ),
                label: 'Gelen Kutusu',
              ),
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              const NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Etkinlik',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: 'Hesap',
              ),
            ],
          ),
        );
      },
    );
  }
}
