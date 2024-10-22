import 'package:flutter/material.dart';
import 'package:insee_builder/locator.dart';

import '../../service/service.dart';
import '../notifiers.dart';
import '../ui.dart';

class LocaleSelectorView extends StatelessWidget {
  const LocaleSelectorView({Key? key, required this.onDone}) : super(key: key);

  final Function() onDone;

  handleLocaleSelect(String locale) async {
    await locate<AppPreference>().writeLocalePreference(locale);
    locate<AppLocaleNotifier>().setLocale(Locale(locale));
    onDone();
  }

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
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LanguageListItem(
                    title: "සිංහල භාෂාව තෝරා ගන්න",
                    onSelect: () => handleLocaleSelect('si'),
                  ),
                  const SizedBox(height: 30),
                  LanguageListItem(
                    title: "தமிழ் மொழியை தேர்ந்தெடுக்கவும்",
                    onSelect: () => handleLocaleSelect('ta'),
                  ),
                  const SizedBox(height: 30),
                  LanguageListItem(
                    title: "Select English Language",
                    onSelect: () => handleLocaleSelect('en'),
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

class LanguageListItem extends StatelessWidget {
  const LanguageListItem({
    Key? key,
    required this.title,
    required this.onSelect,
  }) : super(key: key);

  final Function() onSelect;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Colors.black12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
