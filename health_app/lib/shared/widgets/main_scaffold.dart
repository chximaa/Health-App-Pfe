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

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    DashboardScreen(),
    SymptomsScreen(),
    AnalyticsScreen(),
    MedicationsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.health_and_safety_rounded, label: 'Symptoms'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics'),
    _NavItem(icon: Icons.medication_rounded, label: 'Meds'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _FloatingPillNav(
        selectedIndex: _selectedIndex,
        items: _navItems,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _FloatingPillNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _FloatingPillNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final isSelected = selectedIndex == i;
            return _NavButton(
              item: items[i],
              isSelected: isSelected,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(
          item.icon,
          size: 22,
          color: isSelected ? Colors.white : AppColors.textHint,
        ),
      ),
    );
  }
}
