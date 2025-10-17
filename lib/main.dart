import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:menu_app/src/common/controller_observer.dart';
import 'package:menu_app/src/common/navigator/app_navigator.dart';
import 'package:menu_app/src/common/navigator/app_route_observer.dart';
import 'package:menu_app/src/common/navigator/pages.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<void>(
  () async {
    WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.allowFirstFrame();
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    builder: (context, child) =>
        AppNavigator(key: builderKey, pages: const [DashboardPage()], observers: [AppRouteObserver()]),
  );
}
