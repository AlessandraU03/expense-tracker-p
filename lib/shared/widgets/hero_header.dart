import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 8, 24, 28),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: padding.copyWith(top: padding.top + topInset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: child,
    );
  }
}
