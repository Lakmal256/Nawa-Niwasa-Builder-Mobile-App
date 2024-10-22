import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insee_builder/util/util.dart';

import '../../localizations.dart';

abstract class ImageBoxItem {
  ImageBoxItem(this.name, {this.data});

  String name;

  String? data;

  ImageProvider get imageProvider;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImageBoxItem && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class FileImageBoxItem extends ImageBoxItem {
  FileImageBoxItem(super.name, {required this.file, super.data});

  final File file;

  @override
  ImageProvider<Object> get imageProvider => FileImage(file);
}

class NetworkImageBoxItem extends ImageBoxItem {
  NetworkImageBoxItem(super.name, {required this.url, super.data});

  final String url;

  @override
  ImageProvider<Object> get imageProvider => NetworkImage(url);
}

class ImageBoxControllerValue {
  List<ImageBoxItem> items;

  ImageBoxControllerValue.empty() : items = List.empty(growable: true);
}

class ImageBoxController extends ValueNotifier<ImageBoxControllerValue> {
  ImageBoxController({ImageBoxControllerValue? initialValue}) : super(initialValue ?? ImageBoxControllerValue.empty());

  addAll(List<ImageBoxItem> items) {
    value.items.addAll(items);
    notifyListeners();
  }

  addImage(ImageBoxItem item) {
    value.items.add(item);
    notifyListeners();
  }

  removeItem(ImageBoxItem item) {
    value.items.remove(item);
    notifyListeners();
  }

  clear() {
    value.items.clear();
    notifyListeners();
  }

  replaceAll(List<ImageBoxItem> items) {
    value.items = items;
    notifyListeners();
  }
}

/// Store files in memory; not in the server
/// Read the controller value on submission or validation
class FileImageBox extends StatelessWidget {
  final ImageBoxController controller;

  const FileImageBox({super.key, required this.controller});

  Widget buildItem(BuildContext context, int index) {
    var item = controller.value.items[index];
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Image(image: item.imageProvider),

        /// Uploaded indicator
        if (item is NetworkImageBoxItem)
          const Positioned(
            top: 10,
            left: 10,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: Colors.black26,
              ),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        Positioned(
          right: 10,
          bottom: 10,
          child: FilledButton(
            onPressed: () => controller.removeItem(item),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
            // Delete
            child: Text(AppLocalizations.of(context)!.nN_1001),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        return Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(15)),
          child: ListView.separated(
            padding: const EdgeInsets.all(15),
            scrollDirection: Axis.horizontal,
            itemCount: value.items.length,
            separatorBuilder: (context, i) => const SizedBox(width: 10),
            itemBuilder: buildItem,
          ),
        );
      },
    );
  }
}
