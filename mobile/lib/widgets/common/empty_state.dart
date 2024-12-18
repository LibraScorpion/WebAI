import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    Key? key,
    required this.message,
    this.description,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

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
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyChat extends EmptyState {
  const EmptyChat({
    Key? key,
    VoidCallback? onAction,
  }) : super(
          key: key,
          message: 'No Messages Yet',
          description: 'Start a conversation by sending a message',
          icon: Icons.chat_bubble_outline,
          onAction: onAction,
          actionLabel: 'Start Chat',
        );
}

class EmptySearch extends EmptyState {
  const EmptySearch({
    Key? key,
    VoidCallback? onAction,
  }) : super(
          key: key,
          message: 'No Results Found',
          description: 'Try different keywords or filters',
          icon: Icons.search_off,
          onAction: onAction,
          actionLabel: 'Clear Search',
        );
}

class EmptyHistory extends EmptyState {
  const EmptyHistory({
    Key? key,
    VoidCallback? onAction,
  }) : super(
          key: key,
          message: 'No History',
          description: 'Your history will appear here',
          icon: Icons.history,
          onAction: onAction,
          actionLabel: 'Start Now',
        );
}

class EmptyNotifications extends EmptyState {
  const EmptyNotifications({
    Key? key,
    VoidCallback? onAction,
  }) : super(
          key: key,
          message: 'No Notifications',
          description: 'You\'re all caught up!',
          icon: Icons.notifications_none,
          onAction: onAction,
          actionLabel: null,
        );
}

class EmptyImages extends EmptyState {
  const EmptyImages({
    Key? key,
    VoidCallback? onAction,
  }) : super(
          key: key,
          message: 'No Images',
          description: 'Generate your first image',
          icon: Icons.image_not_supported,
          onAction: onAction,
          actionLabel: 'Generate Image',
        );
}
