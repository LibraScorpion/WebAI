import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

class SearchAppBar extends CustomAppBar {
  final TextEditingController searchController;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String hintText;

  SearchAppBar({
    Key? key,
    required this.searchController,
    this.onClear,
    this.onSubmitted,
    this.onChanged,
    this.hintText = 'Search',
    List<Widget>? actions,
  }) : super(
          key: key,
          title: '',
          actions: actions,
          centerTitle: false,
        );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    onClear?.call();
                  },
                )
              : null,
        ),
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: actions,
    );
  }
}

class SliversAppBar extends CustomAppBar {
  final Widget? flexibleSpace;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;

  const SliversAppBar({
    Key? key,
    required String title,
    this.flexibleSpace,
    this.expandedHeight = 200.0,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    double elevation = 0,
    Color? backgroundColor,
    PreferredSizeWidget? bottom,
  }) : super(
          key: key,
          title: title,
          actions: actions,
          leading: leading,
          centerTitle: centerTitle,
          elevation: elevation,
          backgroundColor: backgroundColor,
          bottom: bottom,
        );

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
    );
  }
}
