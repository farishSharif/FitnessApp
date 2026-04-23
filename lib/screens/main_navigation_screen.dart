import 'package:flutter/material.dart';
import 'workouts_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WorkoutsScreen(),
    const CalendarScreen(),
    const StatsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_rounded, 'Workouts'),
    _NavItem(Icons.calendar_today_rounded, Icons.calendar_today_rounded, 'Calendar'),
    _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Stats'),
    _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Coach'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                return _buildNavItem(index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? Colors.white : const Color(0xFF505050),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF505050),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}
