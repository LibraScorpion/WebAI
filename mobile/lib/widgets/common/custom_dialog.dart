import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final bool dismissible;
  final EdgeInsets contentPadding;
  final EdgeInsets actionsPadding;

  const CustomDialog({
    Key? key,
    required this.title,
    this.message,
    this.content,
    this.actions,
    this.dismissible = true,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.actionsPadding = const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => dismissible,
      child: AlertDialog(
        title: Text(title),
        content: content ??
            (message != null
                ? Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : null),
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        actions: actions,
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool dismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        dismissible: dismissible,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> showMessageDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    bool dismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        dismissible: dismissible,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? message,
    String? initialValue,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool dismissible = true,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => CustomDialog(
        title: title,
        dismissible: dismissible,
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message != null) ...[
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                decoration: const InputDecoration(
                  isDense: true,
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, controller.text);
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<List<String>?> showMultipleChoiceDialog<T>(
    BuildContext context, {
    required String title,
    String? message,
    required List<String> options,
    List<String>? initialSelection,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool dismissible = true,
  }) {
    final selected = List<String>.from(initialSelection ?? []);

    return showDialog<List<String>>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => CustomDialog(
          title: title,
          dismissible: dismissible,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message != null) ...[
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              ...options.map(
                (option) => CheckboxListTile(
                  title: Text(option),
                  value: selected.contains(option),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        selected.add(option);
                      } else {
                        selected.remove(option);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: Text(confirmText),
            ),
          ],
        ),
      ),
    );
  }
}
