import 'dart:async';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<void>(
  () async {},
  (error, stackTrace) => print('$error\n$stackTrace'), // ignore: avoid_print
);
