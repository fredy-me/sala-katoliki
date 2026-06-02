import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.text, height: 1.2),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
      ),
    );
  }
}
