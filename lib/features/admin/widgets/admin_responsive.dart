import 'package:flutter/material.dart';

class AdminResponsive {
  static const double desktopBreakpoint = 900;
  static const double maxContentWidth = 1180;

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }

  static EdgeInsetsGeometry pagePadding(BuildContext context) {
    return EdgeInsets.all(isDesktop(context) ? 24 : 16);
  }
}

class AdminPageShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;
  final Alignment alignment;

  const AdminPageShell({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = AdminResponsive.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? AdminResponsive.pagePadding(context),
          child: child,
        ),
      ),
    );
  }
}
