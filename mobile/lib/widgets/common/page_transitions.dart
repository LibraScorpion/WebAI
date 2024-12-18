import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
              case SlideDirection.left:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case SlideDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
            }

            var tween = Tween(begin: begin, end: Offset.zero)
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

enum SlideDirection {
  right,
  left,
  up,
  down,
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: curve),
              ),
              child: child,
            );
          },
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              alignment: alignment,
              scale: animation.drive(
                Tween(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: curve),
                ),
              ),
              child: child,
            );
          },
        );
}

class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  final PageTransitionType type;
  final Duration duration;
  final Curve curve;

  const CustomPageTransitionsBuilder({
    this.type = PageTransitionType.rightToLeft,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
          ),
          child: child,
        );
      case PageTransitionType.rightToLeft:
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)),
          ),
          child: child,
        );
      case PageTransitionType.leftToRight:
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)),
          ),
          child: child,
        );
      case PageTransitionType.bottomToTop:
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)),
          ),
          child: child,
        );
      case PageTransitionType.topToBottom:
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)),
          ),
          child: child,
        );
    }
  }
}

enum PageTransitionType {
  fade,
  scale,
  rightToLeft,
  leftToRight,
  bottomToTop,
  topToBottom,
}
