import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:insee_builder/locator.dart';
import 'package:insee_builder/service/service.dart';

import 'ui/notifiers.dart';
import 'ui/ui.dart';

Future<bool> _isLocaleExists() async {
  final locale = await locate<AppPreference>().readLocalePreference();
  if (locale == null) return false;

  locate<AppLocaleNotifier>().setLocale(locale);
  return true;
}

final GlobalKey<NavigatorState> mainNavigationKey = GlobalKey();

final routerRefreshListenable = Listenable.merge([
  locate<AuthSessionShockerEventHandler>(),
]);

GoRouter baseRouter = GoRouter(
  initialLocation: "/",
  navigatorKey: mainNavigationKey,
  refreshListenable: routerRefreshListenable,
  redirect: (context, state) {
    if (locate<AuthSessionShockerEventHandler>().value is Exception) return "/login";
    return null;
  },
  routes: [
    GoRoute(
      path: "/",
      redirect: (context, state) async {
        return await _isLocaleExists() ? "/login" : "/locale";
      },
    ),

    GoRoute(
      path: "/login",
      builder: (context, state) => const MobileVerifierFormStandaloneView(),
    ),

    GoRoute(
      path: "/locale",
      parentNavigatorKey: mainNavigationKey,
      builder: (context, state) => LocaleSelectorView(
        onDone: () => GoRouter.of(context).go("/"),
      ),
    ),

    ShellRoute(
      builder: (context, state, child) => MainView(child: child),
      routes: [
        GoRoute(
          path: "/jobs",
          builder: (context, state) => const MainJobView(),
        ),
        GoRoute(
          path: "/profile",
          builder: (context, state) => const ProfileView(),
        ),
        GoRoute(
          path: "/messages",
          builder: (context, state) => const MyMessagesView(),
        ),
        GoRoute(
          path: "/chat",
          builder: (context, state) => ChatView(
            id: int.tryParse(state.queryParams['id'] ?? ''),
            name: state.queryParams['name'],
            email: state.queryParams['email'],
          ),
        ),
        GoRoute(
          path: "/notification",
          builder: (context, state) => const NotificationsView(),
        ),
      ],
    ),

    /// Dev Routes
    ShellRoute(
      builder: (context, state, child) => Showcase(page: child),
      routes: [
        GoRoute(path: "/form", builder: (context, state) => TestFormPage()),
        GoRoute(path: "/typography", builder: (context, state) => const TypographyCatalog()),
      ],
    ),
  ],
);

/// Proxy functions for navigation
goLocation(BuildContext context, String location, {Object? extra}) => GoRouter.of(context).go(location, extra: extra);

Future<T?> pushLocation<T>(BuildContext context, String location, {Object? extra}) =>
    GoRouter.of(context).push<T?>(location, extra: extra);
