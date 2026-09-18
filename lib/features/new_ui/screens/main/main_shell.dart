import 'package:flutter/material.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/features/tahderi/presentation/screens/tahderi/tahderi_page.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    TahderiPage(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  static const List<_NavItem> _items = [
    _NavItem(
        label: 'الرئيسية',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded),
    _NavItem(
        label: 'تحضيري',
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment_rounded),
    _NavItem(
        label: 'بحث',
        icon: Icons.search_rounded,
        activeIcon: Icons.search_rounded),
    _NavItem(
        label: 'المفضلة',
        icon: Icons.favorite_border_rounded,
        activeIcon: Icons.favorite_rounded),
    _NavItem(
        label: 'الإعدادات',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 72, // Increased from 64
                child: Row(
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    final isSelected = index == _currentIndex;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4, // Reduced from 6
                            vertical: 6,   // Reduced from 8
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4), // Reduced from 6
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryVeryLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textLight,
                                size: 24,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
