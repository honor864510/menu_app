import 'package:flutter/material.dart';
import 'package:menu_app/src/feature/home/widget/dashboard_screen.dart';
import 'package:menu_app/src/feature/menu/widget/meals_screen.dart';
import 'package:menu_app/src/feature/settings/widget/settings_screen.dart';

/// Type definition for the page.
@immutable
sealed class AppPage extends MaterialPage<void> {
  const AppPage({
    required String super.name,
    required Map<String, Object?>? super.arguments,
    required super.child,
    required LocalKey super.key,
  });

  @override
  String get name => super.name ?? 'Unknown';

  abstract final Set<String> tags;

  @override
  Map<String, Object?> get arguments => switch (super.arguments) {
    Map<String, Object?> args when args.isNotEmpty => args,
    _ => const <String, Object?>{},
  };

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPage && key == other.key;
}

// Meals page

class DashboardPage extends AppPage {
  const DashboardPage({this.tags = const <String>{'dashboard', 'auth'}})
    : super(name: '/', arguments: null, child: const DashboardScreen(), key: const ValueKey('DashboardPage'));

  @override
  final Set<String> tags;
}

class SettingsPage extends AppPage {
  const SettingsPage({this.tags = const <String>{'settings', 'auth'}})
    : super(name: '/settings', arguments: null, child: const SettingsScreen(), key: const ValueKey('SettingsPage'));

  @override
  final Set<String> tags;
}

class MealsPage extends AppPage {
  const MealsPage({this.tags = const <String>{'meals', 'auth'}})
    : super(name: '/meals', arguments: null, child: const MealsScreen(), key: const ValueKey('MealsPage'));

  @override
  final Set<String> tags;
}
