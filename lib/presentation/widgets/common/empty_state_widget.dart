import 'package:flutter/material.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.search_off,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                width: 200,
                backgroundColor: Colors.grey[800],
              ),
            ],
          ],
        ),
      ),
    );
  }
}