import 'package:flutter/material.dart';

/// Scaffold wrapper for shell tab pages — common AppBar styling, FAB slot,
/// and consistent body padding hooks.
///
/// As of the navigation redesign, top-level tabs no longer host a drawer,
/// so this widget simply standardises the AppBar across tabs and saves a
/// bit of boilerplate. The bottom nav is owned by the parent shell.
class ShellTabScaffold extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;

  const ShellTabScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
  });

  /// Convenience constructor with a plain string title.
  ShellTabScaffold.simple({
    super.key,
    required String title,
    this.actions,
    required this.body,
    this.floatingActionButton,
  }) : title = Text(title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Shell tabs are reached via the bottom bar — no drawer/back button
        // on the root level.
        automaticallyImplyLeading: false,
        title: title,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
