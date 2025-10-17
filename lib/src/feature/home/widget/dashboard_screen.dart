import 'package:flutter/material.dart';
import 'package:menu_app/src/common/navigator/app_route_observer.dart';
import 'package:menu_app/src/common/navigator/pages.dart';
import 'package:menu_app/src/feature/menu/widget/meals_screen.dart';
import 'package:menu_app/src/feature/settings/widget/settings_screen.dart';

/// {@template dashboard_screen}
/// DashboardScreen widget.
/// {@endtemplate}
class DashboardScreen extends StatefulWidget {
  /// {@macro dashboard_screen}
  const DashboardScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _screens = [MealsScreen(), SettingsScreen()];
  static const _pages = [MealsPage(), SettingsPage()];

  int _selectedIndex = 0;

  void _onChangePage(int value) {
    if (value == _selectedIndex) return;

    AppRouteObserver.logNavigationEvent(
      'CHANGE',
      current: _pages[value].createRoute(context),
      previous: _pages[_selectedIndex].createRoute(context),
    );

    _selectedIndex = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _selectedIndex, children: _screens),
    bottomNavigationBar: BottomNavigationBar(
      onTap: _onChangePage,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );
}
