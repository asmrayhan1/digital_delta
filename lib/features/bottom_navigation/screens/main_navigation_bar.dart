import 'package:flutter/material.dart';

import '../../assets/screens/assets_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../map/screens/map_screens.dart';
import '../../profile/screens/profile_screen.dart';
import '../../sync/screens/sync_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    AssetsScreen(),
    MapScreens(),
    SyncScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      /// BODY
      body: screens[currentIndex],

      /// BOTTOM NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF071A2F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(icon: Icons.grid_view, index: 0),
            _navItem(icon: Icons.inventory_2, index: 1),
            _navItem(icon: Icons.map, index: 2),
            _navItem(icon: Icons.sync, index: 3),
            _navItem(icon: Icons.person, index: 4),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// NAV ITEM
  ////////////////////////////////////////////////////////////
  Widget _navItem({required IconData icon, required int index}) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0D2A47)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white54,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PLACEHOLDER SCREEN (REPLACE WITH REAL SCREENS)
////////////////////////////////////////////////////////////
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}