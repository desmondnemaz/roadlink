import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/dependency_injection/injection_container.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/community/presentation/cubit/community_cubit.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/settings/presentation/cubit/theme_cubit.dart';

typedef MyApp = RoadlinkApp;

/// Root widget of the Roadlink application.
class RoadlinkApp extends StatelessWidget {
  const RoadlinkApp({super.key});

  static const SystemUiOverlayStyle _statusBarStyle = SystemUiOverlayStyle(
    statusBarColor: AppPalette.navy900,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) =>
              sl.isRegistered<ThemeCubit>() ? sl<ThemeCubit>() : ThemeCubit(),
        ),
        BlocProvider<LocationCubit>(
          create: (_) => sl.isRegistered<LocationCubit>()
              ? sl<LocationCubit>()
              : LocationCubit(),
        ),
        BlocProvider<CommunityCubit>(
          create: (_) => sl.isRegistered<CommunityCubit>()
              ? sl<CommunityCubit>()
              : CommunityCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Roadlink',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const AppScrollBehavior(),
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: _statusBarStyle,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
