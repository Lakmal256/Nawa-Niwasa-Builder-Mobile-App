import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:insee_builder/ui/notifiers.dart';
import 'package:insee_builder/ui/popup.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'locator.dart';
import 'router.dart';
import 'ui/ui.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: event.notification?.title ?? "",
          subtitle: event.notification?.body ?? "",
          color: Colors.black,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        return MaterialApp.router(
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (child != null) child,
                if (locate<ProgressIndicatorController>().value) const ProgressIndicatorPopup(),
                ConnectivityIndicator(),
                Align(
                  alignment: Alignment.topLeft,
                  child: PopupContainer(
                    children: locate<PopupController>().value,
                  ),
                )
              ],
            );
          },
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            ...GlobalMaterialLocalizations.delegates,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('si'), // Sinhala
            Locale('ta'), // Tamil
          ],
          locale: locate<AppLocaleNotifier>().value,
          theme: AppTheme.light,
          routerConfig: baseRouter,
        );
      },
    );
  }

  Listenable get listenable => Listenable.merge([
        locate<AppLocaleNotifier>(),
        locate<PopupController>(),
        locate<ProgressIndicatorController>(),
      ]);
}
