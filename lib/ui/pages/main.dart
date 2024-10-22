import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../localizations.dart';
import '../ui.dart';

class MainView extends StatelessWidget {
  const MainView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWithNotifications(canGoBack: false),
      body: child,
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BottomNavigationItem(
                  // title: "Home",
                  title: AppLocalizations.of(context)!.nN_1024,
                  onTap: () => GoRouter.of(context).go("/jobs"),
                  isActive: true,
                  icon: const Icon(Icons.home_outlined),
                ),
              ),
              Expanded(
                child: BottomNavigationItem(
                  // title: "Messages",
                  title: AppLocalizations.of(context)!.nN_1025,
                  // disabled: true,
                  onTap: () => GoRouter.of(context).go("/messages"),
                  isActive: false,
                  icon: const Icon(Icons.messenger_outline_rounded),
                ),
              ),
              Expanded(
                child: BottomNavigationItem(
                  // title: "Profile",
                  title: AppLocalizations.of(context)!.nN_1026,
                  // disabled: true,
                  onTap: () => GoRouter.of(context).go("/profile"),
                  isActive: false,
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  const BottomNavigationItem({
    Key? key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.disabled = false,
    required this.title,
  }) : super(key: key);

  final Widget icon;
  final Function() onTap;
  final bool isActive;
  final bool disabled;
  final String title;

  @override
  Widget build(BuildContext context) {
    Color color = isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              // dimension: 35,
              dimension: 35,
              child: FittedBox(
                fit: BoxFit.fill,
                child: icon,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title),
            ),
          ],
        ),
      ),
    );
  }
}
