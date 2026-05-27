import 'package:flutter/material.dart';
import '../router/scaffold_key.dart';

/// Scaffold wrapper for shell tab pages.
/// Automatically provides hamburger menu → drawer.
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

  /// Convenience constructor with plain string title.
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
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => shellScaffoldKey.currentState?.openDrawer(),
        ),
        title: title,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
