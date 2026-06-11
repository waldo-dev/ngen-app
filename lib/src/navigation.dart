import 'package:app/core/theme/ngen_theme.dart';
import 'package:app/src/model/BottomNavBarItem.dart';
import 'package:app/src/pages/map/map.dart';
import 'package:app/src/pages/profile/settings.dart';
import 'package:app/src/pages/search.dart';
import 'package:app/src/util/colors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:app/l10n/app_localizations.dart';
// final FirebaseAuth _auth = FirebaseAuth.instance;

class Navigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavigationState();
  }
}

class _NavigationState extends State<Navigation> {
  PersistentTabController _controller = PersistentTabController(initialIndex: 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> _buildScreens() {
    List<Widget> screens = [];

    screens.add(SearchWidget());
    screens.add(MapWidget());
    // screens.add(CollectionWidget());
    screens.add(SettingsWidget());
    return screens;
  }

  List<BottomNavBarItem> _navBarsItems() {
    List<BottomNavBarItem> tabs = [];

    tabs.add(BottomNavBarItem(
      icon: "assets/images/navigation/search.svg",
      title: (AppLocalizations.of(context)!.titleExplore.toUpperCase()),
      textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.secondary,
    ));

    tabs.add(BottomNavBarItem(
      icon: "assets/images/navigation/map.svg",
      title: (AppLocalizations.of(context)!.titleMap.toUpperCase()),
      textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.secondary,
    ));
    //
    // tabs.add(BottomNavBarItem(
    //   icon: "assets/images/navigation/file.svg",
    //   title: ("COLECCIONES"),
    //   textStyle: TextStyle(fontFamily: "Open Sans", fontSize: 9, fontWeight: FontWeight.bold),
    //   activeColorPrimary: AppColors.primary,
    //   inactiveColorPrimary: AppColors.secondary,
    // ));

    tabs.add(BottomNavBarItem(
      icon: "assets/images/navigation/user.svg",
      title: (AppLocalizations.of(context)!.titleProfile.toUpperCase()),
      textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.secondary,
    ));

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _controller,
      screens: _buildScreens(),
      // items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: AppColors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true,
      // Default is true.
      hideNavigationBarWhenKeyboardShows: true,
      // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      // decoration: NavBarDecoration(
      //   borderRadius: BorderRadius.only(
      //     topRight: Radius.circular(10.0),
      //     topLeft: Radius.circular(10.0),
      //   ),
      //   colorBehindNavBar: AppColors.primary,
      //   border: Border.all(color: Colors.white),
      // ),
      // popAllScreensOnTapOfSelectedTab: true,
      // popActionScreens: PopActionScreensType.all,
      // itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
      //   duration: Duration(milliseconds: 200),
      //   curve: Curves.ease,
      // ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 300),
      ),
      // navBarStyle: NavBarStyle.simple, // Choose the nav bar style with this property.
      itemCount: _navBarsItems().length,
      customWidget: CustomNavBarWidget(
        // Your custom widget goes here
        items: _navBarsItems(),
        selectedIndex: _controller.index,
        onItemSelected: (index) {
          setState(() {
            _controller.index = index; // NOTE: THIS IS CRITICAL!! Don't miss it!
          });
        },
      ),
    );
  }
}

class CustomNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavBarItem> items; // NOTE: You CAN declare your own model here instead of `PersistentBottomNavBarItem`.
  final ValueChanged<int> onItemSelected;

  CustomNavBarWidget({
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  Widget _buildItem(BuildContext context, BottomNavBarItem item, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      height: 60.0,
      color: isSelected ? AppColors.navSelected : Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                  size: 26.0,
                  color: isSelected
                      ? (item.activeColorSecondary == null ? item.activeColorPrimary : item.activeColorSecondary)
                      : item.inactiveColorPrimary == null
                          ? item.activeColorPrimary
                          : item.inactiveColorPrimary),
              child: SvgPicture.asset(
                item.icon,
                color: isSelected ? item.activeColorPrimary : item.inactiveColorPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Material(
              type: MaterialType.transparency,
              child: FittedBox(
                  child: Text(
                item.title!,
                style: NgenTheme.navLabel(context, selected: isSelected).copyWith(
                  color: isSelected
                      ? (item.activeColorSecondary ?? item.activeColorPrimary)
                      : item.inactiveColorPrimary,
                ),
              )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            int index = items.indexOf(item);
            return Flexible(
              child: GestureDetector(
                onTap: () {
                  this.onItemSelected(index);
                },
                child: _buildItem(context, item, selectedIndex == index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

