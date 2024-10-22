import 'package:flutter/material.dart';

class PageActionHandler<T> extends StatelessWidget {
  const PageActionHandler({
    super.key,
    required this.action,
    required this.errorBuilder,
    required this.progressBuilder,
    required this.builder,
  });

  final Future<T> action;
  final Widget Function(BuildContext context, T? data) builder;
  final Widget Function(BuildContext context, Object? error) errorBuilder;
  final Widget Function(BuildContext context) progressBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: action,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return progressBuilder(context);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return errorBuilder(context, snapshot.error);
        }

        return builder(context, snapshot.data);
      },
    );
  }
}