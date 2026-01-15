// Deprecated: use `lib/core/widgets/my_textformfield.dart` instead.
// This file is left for backward compatibility and will be removed in a later cleanup.

import 'package:flutter/material.dart';

class MyTextformfield extends StatelessWidget {
  const MyTextformfield({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: labelText,
        hintText: hintText,
      ),
    );
  }
}