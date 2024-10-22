import 'package:flutter/material.dart';

import '../../localizations.dart';
import '../ui.dart';

class RoleSelectorView extends StatelessWidget {
  const RoleSelectorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2,
              child: FractionallySizedBox(
                widthFactor: .5,
                child: Image.asset(
                  "assets/images/tm_001.png",
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                // "BUILDER REGISTER WITH NAWA NIWASA",
                AppLocalizations.of(context)!.nN_1075.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                // "Are you a Builder or a Contractor?",
                AppLocalizations.of(context)!.nN_1076,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black45,
                    ),
              ),
            ),
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RoleListItem(roleType: RoleType.builder),
                  SizedBox(height: 15),
                  RoleListItem(roleType: RoleType.contractor),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Text(
                    // "Need any help?",
                    AppLocalizations.of(context)!.nN_1077,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "0117800801",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.red,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum RoleType { contractor, builder }

class RoleListItem extends StatelessWidget {
  const RoleListItem({
    Key? key,
    required this.roleType,
  }) : super(key: key);

  final RoleType roleType;

  Widget _buildContent(BuildContext context, String title, Widget icon) {
    return Row(
      children: [
        SizedBox.square(
          dimension: 25,
          child: icon,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    late Widget child;

    switch (roleType) {
      case RoleType.builder:
        child = _buildContent(
          context,
          // "Yes, I’m a Builder",
          AppLocalizations.of(context)!.nN_1078,
          Image.asset(
            "assets/icons/icon_001.png",
            fit: BoxFit.fitWidth,
          ),
        );
      case RoleType.contractor:
        child = _buildContent(
          context,
          // "Yes, I’m a Contractor",
          AppLocalizations.of(context)!.nN_1079,
          Image.asset(
            "assets/icons/icon_002.png",
            fit: BoxFit.fitWidth,
          ),
        );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Colors.black12),
      ),
      child: child,
    );
  }
}
