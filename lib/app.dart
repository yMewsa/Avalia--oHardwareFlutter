import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'utils/app_routes.dart';
import 'views/history_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Ponto',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.home: (_) => const HomeView(),
        AppRoutes.history: (_) => const HistoryView(),
      },
    );
  }
}
