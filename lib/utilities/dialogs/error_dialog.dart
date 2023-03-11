import 'package:flutter/material.dart';
import 'package:makenote/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Error Occored: ',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
