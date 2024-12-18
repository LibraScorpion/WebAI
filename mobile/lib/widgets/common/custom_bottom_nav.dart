import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomBottomNavItem> items;
  final Color? backgroundColor;
  final double elevation;
  final double iconSize;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.elevation = 8.0,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.black12,
              blurRadius: elevation,
            ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: iconSize,
                        color: isSelected
                            ? selectedItemColor ?? theme.colorScheme.primary
                            : unselectedItemColor ?? theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? selectedItemColor ?? theme.colorScheme.primary
                              : unselectedItemColor ?? theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CustomBottomNavItem({
    required this.icon,
    IconData? activeIcon,
    required this.label,
  }) : activeIcon = activeIcon ?? icon;
}

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomBottomNavItem> items;
  final Color? backgroundColor;
  final double elevation;
  final double iconSize;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Curve curve;
  final Duration duration;

  const AnimatedBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.elevation = 8.0,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: Colors.black12,
              blurRadius: elevation,
            ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: duration,
                        curve: curve,
                        padding: EdgeInsets.all(isSelected ? 8 : 0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (selectedItemColor ?? theme.colorScheme.primary)
                                  .withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: iconSize,
                          color: isSelected
                              ? selectedItemColor ?? theme.colorScheme.primary
                              : unselectedItemColor ?? theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: duration,
                        curve: curve,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? selectedItemColor ?? theme.colorScheme.primary
                              : unselectedItemColor ?? theme.colorScheme.onSurface,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
