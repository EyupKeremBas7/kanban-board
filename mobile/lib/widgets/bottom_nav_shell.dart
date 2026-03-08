import 'package:flutter/material.dart';
import 'package:mobile/screens/boards.dart';
import 'package:mobile/screens/inbox.dart';
import 'package:mobile/screens/planner.dart';
import 'package:mobile/screens/activity.dart';
import 'package:mobile/screens/account.dart';

/// 5-sekmeli BottomNavigationBar wrapper.
/// Sekmeler: Panolar, Gelen Kutusu, Planlayıcı, Etkinlik, Hesap
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Panolar',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Gelen Kutusu',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planlayıcı',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Etkinlik',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Hesap',
          ),
        ],
      ),
    );
  }
}
