import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:menu_app/src/common/controller_observer.dart';
import 'package:menu_app/src/feature/menu/widget/meals_screen.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<void>(
  () async {
    WidgetsFlutterBinding.ensureInitialized();

    Controller.observer = const ControllerObserver();

    runApp(const MyMaterialApp());
  },
  (error, stackTrace) => print('$error\n$stackTrace'), // ignore: avoid_print
);

/// {@template main}
/// MyMaterialApp widget.
/// {@endtemplate}
class MyMaterialApp extends StatefulWidget {
  /// {@macro main}
  const MyMaterialApp({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<MyMaterialApp> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  // Disable recreate widget tree
  final Key builderKey = GlobalKey();

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: const MealsScreen(),
    builder: (context, child) => KeyedSubtree(key: builderKey, child: child ?? const SizedBox.shrink()),
  );
}
