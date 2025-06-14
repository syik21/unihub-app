import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final double selectedIconSize = 26;
    final double unselectedIconSize = 28;
    return Theme(
      data: Theme.of(context).copyWith(
        //splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: BottomNavigationBar(
          showUnselectedLabels: false,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            fontFamily: 'Nura',
          ),
          currentIndex: currentIndex,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icon/navbar/home-icon.svg',
                height: unselectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'asset/icon/navbar/selected-home.svg',
                height: selectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icon/navbar/map-icon.svg',
                height: unselectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'asset/icon/navbar/selected-map.svg',
                height: selectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              label: "Map",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icon/navbar/scan-icon.svg',
                height: unselectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'asset/icon/navbar/selected-scan.svg',
                height: selectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              label: "Scan",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/icon/navbar/more-icon.svg',
                height: unselectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                'asset/icon/navbar/selected-more.svg',
                height: selectedIconSize,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                  BlendMode.srcIn,
                ),
              ),
              label: "More",
            ),
          ],
        ),
      ),
    );
  }
}
