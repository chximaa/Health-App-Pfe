import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/medications/screens/medications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/symptoms/screens/symptoms_screen.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late List<AnimationController> _iconControllers;

  final List<Widget> _pages = const [
    DashboardScreen(),
    SymptomsScreen(),
    AnalyticsScreen(),
    MedicationsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.health_and_safety_outlined, activeIcon: Icons.health_and_safety_rounded, label: 'Symptoms'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Analytics'),
    _NavItem(icon: Icons.medication_outlined, activeIcon: Icons.medication_rounded, label: 'Meds'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _iconControllers = List.generate(
      _navItems.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
      ),
    );
    _iconControllers[_selectedIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    _iconControllers[_selectedIndex].reverse();
    _iconControllers[index].forward();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _FloatingTabBar(
        selectedIndex: _selectedIndex,
        items: _navItems,
        iconControllers: _iconControllers,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _FloatingTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final List<AnimationController> iconControllers;
  final ValueChanged<int> onTap;

  const _FloatingTabBar({
    required this.selectedIndex,
    required this.items,
    required this.iconControllers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = selectedIndex == i;
              return _TabBarButton(
                item: items[i],
                isSelected: isSelected,
                controller: iconControllers[i],
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabBarButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final AnimationController controller;
  final VoidCallback onTap;

  const _TabBarButton({
    required this.item,
    required this.isSelected,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
