import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_spacing.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? account;
  const AddAccountScreen({super.key, this.account});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'wechat';
  int _colorValue = 0xFF07C160;
  int _iconCodePoint = 0xe3d9;
  bool _saving = false;

  bool get _isEditing => widget.account != null;

  static const _types = [
    ('wechat', '微信', Icons.chat_rounded, 0xFF07C160),
    ('alipay', '支付宝', Icons.account_balance_wallet_rounded, 0xFF1677FF),
    ('bank_card', '银行卡', Icons.credit_card_rounded, 0xFFD4914A),
    ('cash', '现金', Icons.attach_money_rounded, 0xFF795548),
    ('other', '其他', Icons.more_horiz_rounded, 0xFF78909C),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance?.toString() ?? '';
      _type = widget.account!.type;
      _colorValue = widget.account!.colorValue;
      _iconCodePoint = widget.account!.iconCodePoint;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入账户名称')),
      );
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now();
    final account = Account(
      id: widget.account?.id ?? const Uuid().v4(),
      name: name,
      type: _type,
      balance: double.tryParse(_balanceController.text.trim()),
      iconCodePoint: _iconCodePoint,
      colorValue: _colorValue,
      sortOrder: widget.account?.sortOrder ?? 99,
      createdAt: widget.account?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEditing) {
        await AccountRepository().update(account);
      } else {
        await AccountRepository().insert(account);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '编辑账户' : '添加账户')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type selector
            Text('账户类型', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _types.map((t) {
                final selected = _type == t.$1;
                return ChoiceChip(
                  label: Text(t.$2),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _type = t.$1;
                    _colorValue = t.$4;
                    _iconCodePoint = t.$3.codePoint;
                  }),
                );
              }).toList(),
            ),
            AppSpacing.gapXl,

            Text('账户名称', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: '如：招商银行储蓄卡'),
            ),
            AppSpacing.gapXl,

            Text('当前余额（可选）', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: '0.00', prefixText: '¥ '),
            ),
            AppSpacing.gapXxl,

            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? '保存修改' : '添加账户'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
