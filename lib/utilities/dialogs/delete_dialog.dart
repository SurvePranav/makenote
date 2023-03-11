import 'package:flutter/material.dart';
import 'package:makenote/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'are you sure you want to Delete this note?',
    optionsBuilder: () => {
      'Cancle': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}
