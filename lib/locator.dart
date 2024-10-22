import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:insee_builder/service/service.dart';
import 'package:insee_builder/ui/indicators.dart';
import 'package:insee_builder/ui/notifiers.dart';
import 'package:insee_builder/ui/popup.dart';

import 'service/fcm.dart';

GetIt getIt = GetIt.instance;

class LocatorConfig {
  LocatorConfig({
    required this.authority,
    this.pathPrefix,
    required this.googleMapApiKey,
  });

  final String authority;

  final String? pathPrefix;

  final String googleMapApiKey;
}

setupServiceLocator(LocatorConfig config) async {
  getIt.registerSingleton(config);

  getIt.registerSingleton(AppLocaleNotifier(const Locale("en")));
  getIt.registerSingleton(AppPreference());

  final authSessionEventHandler = AuthSessionShockerEventHandler();
  final authService = RestAuthService(
    config: RestAuthServiceConfig(
      authority: config.authority,
      pathPrefix: config.pathPrefix,
    ),
  )..setEventHandler(authSessionEventHandler);

  final restService = RestService(
    authService: authService,
    config: RestServiceConfig(
      authority: config.authority,
      pathPrefix: config.pathPrefix,
    ),
  );

  getIt.registerSingleton(authService);
  getIt.registerSingleton(authSessionEventHandler);
  getIt.registerSingleton(restService);

  /// In-App Notifications
  getIt.registerSingleton(InAppNotificationHandler(restService: restService));
  getIt.registerSingleton(CloudMessagingHelperService(restService: restService));

  getIt.registerSingleton(BuilderService(null));
  getIt.registerSingleton(GlobalJobTypes([]));

  getIt.registerLazySingleton(() => ProgressIndicatorController());
  getIt.registerSingleton(PopupController());

  // getIt.registerSingleton(ReverseGeocodingService(apiKey: config.googleMapApiKey));
  getIt.registerSingleton(DeviceLocationService.init());
  getIt.registerSingleton(UserLocationService(null));
}

T locate<T extends Object>() => GetIt.instance<T>();
