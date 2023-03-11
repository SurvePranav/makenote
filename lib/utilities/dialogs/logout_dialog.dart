import 'package:flutter/material.dart';
import 'package:makenote/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'logout',
    content: 'are you sure you want to log out?',
    optionsBuilder: () => {
      'Cancle': false,
      'Log Out': true,
    },
  ).then((value) => value ?? false);
}
