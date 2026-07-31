import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../config/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int _selectedIndex = 0;

  void _selectDestination(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    Modular.to.navigate(switch (index) {
      0 => '/home/',
      1 => '/charts/',
      _ => '/settings/',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: const SafeArea(top: false, child: RouterOutlet()),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: Offset(8, 8),
                  blurRadius: 18,
                ),
                BoxShadow(
                  color: AppColors.highlight,
                  offset: Offset(-8, -8),
                  blurRadius: 18,
                ),
              ],
            ),
            child: NavigationBar(
              height: 68,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectDestination,
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.accent.withValues(alpha: .16),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: AppColors.accent,
                  ),
                  label: 'Hoje',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.accent,
                  ),
                  label: 'Resumo',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(
                    Icons.settings_rounded,
                    color: AppColors.accent,
                  ),
                  label: 'Configurações',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
