import 'package:flutter/material.dart';

void CustomSnackBar(BuildContext context, String text) {
  var snackBar = SnackBar(
    content: Text(text),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
