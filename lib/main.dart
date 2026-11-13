import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadlink/app/app.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/dependency_injection/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppPalette.navy900,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  await initDependencies();
  runApp(const RoadlinkApp());
}
