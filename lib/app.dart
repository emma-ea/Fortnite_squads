import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'injection_container.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart'; // And other global blocs
import 'presentation/routes/app_router.dart';

class SquadFinderApp extends StatelessWidget {
  const SquadFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Retrieve the AuthBloc from DI to pass to Router
    final authBloc = getIt<AuthBloc>();
    final appRouter = AppRouter(authBloc);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc..add(AuthCheckRequested())),
        BlocProvider(create: (_) => getIt<UserBloc>()),
        // Add other global providers here
      ],
      child: PlatformApp.router(
        title: 'Fortnite Squad Finder',
        debugShowCheckedModeBanner: false,

        // Gamer Theme Configuration
        material: (_, __) => MaterialAppRouterData(
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF007BFF), // Fortnite Blue-ish
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF007BFF),
              secondary: Color(0xFF9D00FF), // Epic Purple
            ),
          ),
        ),

        // Router Configuration
        routerConfig: appRouter.router,
      ),
    );
  }
}
