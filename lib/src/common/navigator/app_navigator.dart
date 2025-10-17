import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:menu_app/src/common/navigator/pages.dart';

// --- Navigator --- //

/// Type definition for the navigation state.
typedef AppNavigationState = List<AppPage>;

/// {@template navigator}
/// AppNavigator widget.
/// {@endtemplate}
class AppNavigator extends StatefulWidget {
  /// {@macro navigator}
  AppNavigator({
    required this.pages,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  /// {@macro navigator}
  AppNavigator.controlled({
    required ValueNotifier<AppNavigationState> this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    this.onBackButtonPressed,
    super.key,
  }) : assert(controller.value.isNotEmpty, 'controller cannot be empty'),
       pages = controller.value;

  /// The [AppNavigatorState] from the closest instance of this class
  /// that encloses the given context, if any.
  static AppNavigatorState? maybeOf(BuildContext context) => context.findAncestorStateOfType<AppNavigatorState>();

  /// The navigation state from the closest instance of this class
  /// that encloses the given context, if any.
  static AppNavigationState? stateOf(BuildContext context) => maybeOf(context)?.state;

  /// The navigator from the closest instance of this class
  /// that encloses the given context, if any.
  static NavigatorState? navigatorOf(BuildContext context) => maybeOf(context)?.navigator;

  /// Change the pages.
  static void change(BuildContext context, AppNavigationState Function(AppNavigationState pages) fn) =>
      maybeOf(context)?.change(fn);

  /// Add a page to the stack.
  static void push(BuildContext context, AppPage page) => change(context, (state) => [...state, page]);

  /// Replace the latest instance
  static void replace(BuildContext context, AppPage page) => change(context, (state) => [...state..removeLast(), page]);

  /// Pop the last page from the stack.
  static void pop(BuildContext context) => change(context, (state) {
    if (state.isNotEmpty) state.removeLast();
    return state;
  });

  /// Clear the pages to the initial state.
  static void reset(BuildContext context, AppPage page) {
    final navigator = maybeOf(context);
    if (navigator == null) return;
    navigator.change((_) => navigator.widget.pages);
  }

  /// Initial pages to display.
  final AppNavigationState pages;

  /// The controller to use for the navigator.
  final ValueNotifier<AppNavigationState>? controller;

  /// Guards to apply to the pages.
  final List<AppNavigationState Function(BuildContext context, AppNavigationState state)> guards;

  /// Observers to attach to the navigator.
  final List<NavigatorObserver> observers;

  /// The transition delegate to use for the navigator.
  final TransitionDelegate<Object?> transitionDelegate;

  /// Revalidate the pages.
  final Listenable? revalidate;

  /// The callback function that will be called when the back button is pressed.
  ///
  /// It must return a boolean with true if this navigator will handle the request;
  /// otherwise, return a boolean with false.
  ///
  /// Also you can mutate the [AppNavigationState] to change the navigation stack.
  final ({AppNavigationState state, bool handled}) Function(AppNavigationState state)? onBackButtonPressed;

  @override
  State<AppNavigator> createState() => AppNavigatorState();
}

/// State for widget AppNavigator.
class AppNavigatorState extends State<AppNavigator> with WidgetsBindingObserver {
  /// The current [Navigator] state (null if not yet built).
  NavigatorState? get navigator => _observer.navigator;
  final NavigatorObserver _observer = NavigatorObserver();

  /// The current pages list.
  AppNavigationState get state => _state;

  late AppNavigationState _state;
  List<NavigatorObserver> _observers = const [];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    _state = widget.pages;
    widget.revalidate?.addListener(revalidate);
    _observers = <NavigatorObserver>[_observer, ...widget.observers];
    widget.controller?.addListener(_controllerListener);
    _controllerListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    revalidate();
  }

  @override
  void didUpdateWidget(covariant AppNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.revalidate, oldWidget.revalidate)) {
      oldWidget.revalidate?.removeListener(revalidate);
      widget.revalidate?.addListener(revalidate);
    }
    if (!identical(widget.observers, oldWidget.observers)) {
      _observers = <NavigatorObserver>[_observer, ...widget.observers];
    }
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?.removeListener(_controllerListener);
      widget.controller?.addListener(_controllerListener);
      _controllerListener();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller?.removeListener(_controllerListener);
    widget.revalidate?.removeListener(revalidate);
    super.dispose();
  }
  /* #endregion */

  @override
  Future<bool> didPopRoute() {
    // If the back button handler is defined, call it.
    final backButtonHandler = widget.onBackButtonPressed;
    if (backButtonHandler != null) {
      final result = backButtonHandler(_state.toList());
      change((pages) => result.state);
      return SynchronousFuture(result.handled);
    }

    // Otherwise, handle the back button press with the default behavior.
    if (_state.length < 2) return SynchronousFuture(false);
    _onDidRemovePage(_state.last);
    return SynchronousFuture(true);
  }

  void _setStateToController() {
    if (widget.controller case ValueNotifier<AppNavigationState> controller) {
      controller
        ..removeListener(_controllerListener)
        ..value = _state
        ..addListener(_controllerListener);
    }
  }

  void _controllerListener() {
    final controller = widget.controller;
    if (controller == null || !mounted) return;
    final newValue = controller.value;
    if (identical(newValue, _state)) return;
    final ctx = context;
    final next = widget.guards.fold(newValue.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) {
      _setStateToController(); // Revert the controller value.
    } else {
      _state = UnmodifiableListView<AppPage>(next);
      _setStateToController();
      setState(() {});
    }
  }

  /// Revalidate the pages.
  void revalidate() {
    if (!mounted) return;
    final ctx = context;
    final next = widget.guards.fold(_state.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<AppPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Change the pages.
  void change(AppNavigationState Function(AppNavigationState pages) fn) {
    final prev = _state.toList();
    var next = fn(prev);
    if (next.isEmpty) return;
    if (!mounted) return;
    final ctx = context;
    next = widget.guards.fold(next, (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) return;
    _state = UnmodifiableListView<AppPage>(next);
    _setStateToController();
    setState(() {});
  }

  /// Called when a page is removed from the stack.
  void _onDidRemovePage(Page<Object?> page) {
    // Note: Comparing by key is generally more robust than by instance.
    change((pages) => pages..removeWhere((p) => p.key == page.key));
  }

  @override
  Widget build(BuildContext context) => Navigator(
    pages: _state,
    reportsRouteUpdateToEngine: true,
    onDidRemovePage: _onDidRemovePage,
    observers: _observers,
    transitionDelegate: widget.transitionDelegate,
  );
}
