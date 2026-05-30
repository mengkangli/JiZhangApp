import 'package:flutter/material.dart';
import '../../../core/widgets/shell_tab_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_icon_data.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';
import 'add_account_screen.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<Account> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final accounts = await AccountRepository().getAll();
      if (mounted)
        setState(() {
          _accounts = accounts;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _color(int colorValue) => Color(colorValue);
  IconData _icon(int codePoint) => AppIconData.fromCodePoint(codePoint);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ShellTabScaffold.simple(
      title: '账户',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: '添加账户',
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const AddAccountScreen()),
            );
            if (result == true) _load();
          },
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: '暂无账户',
                  subtitle: '点击右下角按钮添加账户',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    final accent = _color(account.colorValue);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: accent.withValues(alpha: 0.15),
                        child: Icon(_icon(account.iconCodePoint),
                            color: accent, size: 22),
                      ),
                      title: Text(account.name),
                      subtitle: Text(account.typeLabel),
                      trailing: Text(
                        account.balance != null
                            ? '¥${account.balance!.toStringAsFixed(2)}'
                            : '',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => AddAccountScreen(account: account),
                          ),
                        );
                        if (result == true) _load();
                      },
                    );
                  },
                ),
    );
  }
}
