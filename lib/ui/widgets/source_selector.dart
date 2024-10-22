import 'package:flutter/material.dart';
import '../../localizations.dart';
import "../../util/file_pick.dart";
import '../ui.dart';

Future<Source?> showSourceSelector(BuildContext context) =>
    showDialog(context: context, barrierColor: Colors.black12, builder: (context) => const SourceSelector());

class SourceSelector extends StatelessWidget {
  const SourceSelector({Key? key}) : super(key: key);

  Widget buildItem(BuildContext context, Source source) {
    switch (source) {
      case Source.camera:
        return SourceSelectorItem(
          icon: const Icon(Icons.camera_alt_outlined),
          // text: "Camera",
          text: AppLocalizations.of(context)!.nN_1081,
        );
      case Source.gallery:
        return SourceSelectorItem(
          icon: const Icon(Icons.photo_size_select_actual_outlined),
          // text: "Photo & Video Library",
          text: AppLocalizations.of(context)!.nN_1082,
        );
      case Source.files:
        return SourceSelectorItem(
          icon: const Icon(Icons.folder_outlined),
          // text: "Documents",
          text: AppLocalizations.of(context)!.nN_1083,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black26,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: ListView(
              clipBehavior: Clip.antiAlias,
              shrinkWrap: true,
              children: Source.values
                  .map(
                    (source) => RawMaterialButton(
                      onPressed: () => Navigator.of(context).pop(source),
                      child: buildItem(context, source),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FilledButton(
            onPressed: Navigator.of(context).pop,
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              backgroundColor: MaterialStateProperty.all(AppColors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            // "Cancel"
            child: Text(AppLocalizations.of(context)!.nN_1033),
          ),
        )
      ],
    );
  }
}

class SourceSelectorItem extends StatelessWidget {
  const SourceSelectorItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [icon, const SizedBox(width: 15), Text(text, style: Theme.of(context).textTheme.button)],
      ),
    );
  }
}
