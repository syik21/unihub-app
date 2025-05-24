import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unihub/theme/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        fontFamily: 'Nura',
      ),
      selectedItemColor: AppTheme.lightTheme.primaryColor,
      unselectedItemColor: AppTheme.lightTheme.primaryColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('asset/icon/navbar/home-icon.svg', height: 24),
          activeIcon: SvgPicture.asset(
            'asset/icon/navbar/selected-home.svg',
            height: 24,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('asset/icon/navbar/map-icon.svg', height: 24),
          activeIcon: SvgPicture.asset(
            'asset/icon/navbar/selected-map.svg',
            height: 24,
          ),
          label: "Map",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('asset/icon/navbar/scan-icon.svg', height: 24),
          activeIcon: SvgPicture.asset(
            'asset/icon/navbar/selected-scan.svg',
            height: 24,
          ),
          label: "Scan",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('asset/icon/navbar/more-icon.svg', height: 24),
          activeIcon: SvgPicture.asset(
            'asset/icon/navbar/selected-more.svg',
            height: 24,
          ),
          label: "More",
        ),
      ],
    );
  }
}
