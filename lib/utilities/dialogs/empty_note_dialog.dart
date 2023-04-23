import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> cannotShareEmptyNoteDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Empty Note',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
