import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool isDismissible;
  final double? initialChildSize;
  final double? minChildSize;
  final double? maxChildSize;
  final bool enableDrag;
  final Color? backgroundColor;
  final ScrollController? scrollController;

  const CustomBottomSheet({
    Key? key,
    this.title,
    required this.child,
    this.actions,
    this.isDismissible = true,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.9,
    this.enableDrag = true,
    this.backgroundColor,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isDismissible,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enableDrag) _buildDragHandle(context),
            if (title != null) _buildTitle(context),
            Flexible(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: child,
                ),
              ),
            ),
            if (actions != null) _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (isDismissible)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          Expanded(
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions!,
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    List<Widget>? actions,
    bool isDismissible = true,
    double? initialChildSize = 0.5,
    double? minChildSize = 0.25,
    double? maxChildSize = 0.9,
    bool enableDrag = true,
    Color? backgroundColor,
    bool isDraggable = true,
  }) {
    if (isDraggable) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        isDismissible: isDismissible,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: initialChildSize!,
          minChildSize: minChildSize!,
          maxChildSize: maxChildSize!,
          builder: (context, scrollController) => CustomBottomSheet(
            title: title,
            child: child,
            actions: actions,
            isDismissible: isDismissible,
            enableDrag: enableDrag,
            backgroundColor: backgroundColor,
            scrollController: scrollController,
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: title,
        child: child,
        actions: actions,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static Future<T?> showOptions<T>({
    required BuildContext context,
    String? title,
    required List<BottomSheetOption<T>> options,
    bool isDismissible = true,
    Color? backgroundColor,
  }) {
    return show<T>(
      context: context,
      title: title,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      isDraggable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            leading: option.icon != null ? Icon(option.icon) : null,
            title: Text(option.title),
            subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
            onTap: () => Navigator.pop(context, option.value),
          );
        }).toList(),
      ),
    );
  }
}

class BottomSheetOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;

  const BottomSheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
}
