import 'package:flutter/material.dart';

/// Wraps a child that depends on a `DateTime` month so it slides in from
/// the left or right when the month changes.
///
/// Direction is derived from the new month vs. the previous: future
/// months slide in from the right (matches "next" arrow movement),
/// past months from the left.
class MonthAnimatedSwitcher extends StatefulWidget {
  final DateTime month;
  final Widget child;
  final Duration duration;

  const MonthAnimatedSwitcher({
    super.key,
    required this.month,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  State<MonthAnimatedSwitcher> createState() => _MonthAnimatedSwitcherState();
}

class _MonthAnimatedSwitcherState extends State<MonthAnimatedSwitcher> {
  late DateTime _previous;
  bool _slideRight = true;

  @override
  void initState() {
    super.initState();
    _previous = widget.month;
  }

  @override
  void didUpdateWidget(MonthAnimatedSwitcher old) {
    super.didUpdateWidget(old);
    if (widget.month != old.month) {
      _slideRight = widget.month.isAfter(_previous);
      _previous = widget.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final beginOffset = Offset(_slideRight ? 1.0 : -1.0, 0);
        return SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
              .animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      // Key by month so the switcher actually swaps subtrees on change.
      child: KeyedSubtree(
        key: ValueKey(widget.month.millisecondsSinceEpoch),
        child: widget.child,
      ),
    );
  }
}
