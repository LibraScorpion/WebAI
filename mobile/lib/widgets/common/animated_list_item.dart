import 'package:flutter/material.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Curve curve;
  final Offset? offset;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            (1 - value) * (offset?.dy ?? 50.0),
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class AnimatedListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final Duration duration;
  final Curve curve;
  final Offset? offset;

  const AnimatedListView({
    Key? key,
    required this.children,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          duration: duration,
          curve: curve,
          offset: offset,
          child: children[index],
        );
      },
    );
  }
}

class AnimatedGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Duration duration;
  final Curve curve;
  final Offset? offset;

  const AnimatedGridView({
    Key? key,
    required this.children,
    required this.crossAxisCount,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          duration: duration,
          curve: curve,
          offset: offset,
          child: children[index],
        );
      },
    );
  }
}
