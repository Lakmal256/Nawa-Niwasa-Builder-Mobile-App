import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../locator.dart';
import '../../service/service.dart';

class AppBarWithNotifications extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithNotifications({Key? key, required this.canGoBack}) : super(key: key);

  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFECECEC),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // icon,
                SizedBox(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StandaloneNotificationIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class StandaloneNotificationIndicator extends StatelessWidget {
  const StandaloneNotificationIndicator({super.key});

  handleNavigation(BuildContext context) {
    GoRouter.of(context).push("/notification");
  }

  @override
  Widget build(BuildContext context) {
    int count = locate<InAppNotificationHandler>().count;

    return GestureDetector(
      onTap: () => handleNavigation(context),
      child: ListenableBuilder(
        listenable: locate<InAppNotificationHandler>(),
        builder: (context, _) {
          return NotificationIndicator(
            value: count > 0 ? count.toString() : null,
          );
        },
      ),
    );
  }
}

class NotificationIndicator extends StatelessWidget {
  const NotificationIndicator({super.key, required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (value != null)
          Transform.translate(
            offset: const Offset(-18, -10),
            child: TextBadge(value: value!),
          ),
        const Icon(
          Icons.notifications,
          color: Color(0xFF50555C),
          size: 30,
        ),
      ],
    );
  }
}

class TextBadge extends StatelessWidget {
  const TextBadge({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        color: Colors.red,
      ),
      child: Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}