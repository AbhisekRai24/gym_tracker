import 'package:flutter/material.dart';

class AppFeedback {
  AppFeedback._();

  static final messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void success(
    BuildContext context,
    String message,
  ) {
    _showSnackBar(
      context,
      message,
      Icons.check_circle_outline,
    );
  }

  static void error(
    BuildContext context,
    String message,
  ) {
    _showSnackBar(
      context,
      message,
      Icons.error_outline,
    );
  }

  static void info(
    BuildContext context,
    String message,
  ) {
    _showSnackBar(
      context,
      message,
      Icons.info_outline,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    final messenger =
        messengerKey.currentState ??
        ScaffoldMessenger.maybeOf(context);

    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(cancelText),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    )
                  : null,
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}