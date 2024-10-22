import 'package:flutter/material.dart';

import '../../localizations.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.onChange,
    this.hintText,
  });

  final Function(String) onChange;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xF0F0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.search),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  // "SEARCH"
                  hintText: hintText ?? AppLocalizations.of(context)!.nN_1080.toUpperCase(),
                ),
                onChanged: onChange,
              ),
            ),
          ),
          // const Icon(Icons.tune_rounded)
        ],
      ),
    );
  }
}
