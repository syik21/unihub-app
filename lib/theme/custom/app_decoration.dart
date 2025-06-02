import 'package:flutter/material.dart';

class AppDecorations {
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(12),
      boxShadow:
          Theme.of(context).brightness == Brightness.light
              ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
              : [],
    );
  }
}
