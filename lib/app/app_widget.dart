import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../config/app_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute('/home/');

    return MaterialApp.router(
      title: 'Anacronistta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: Modular.routerConfig,
    );
  }
}
