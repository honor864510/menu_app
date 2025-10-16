import 'package:flutter/widgets.dart';

/// {@template dependency_container}
/// DependencyContainer widget.
/// {@endtemplate}
class DependencyContainer extends InheritedWidget {
  /// {@macro dependency_container}
  const DependencyContainer({
    required super.child,
    super.key, // ignore: unused_element_parameter
  });

  @override
  bool updateShouldNotify(covariant DependencyContainer oldWidget) => false;
}
