import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  late String _avatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _budgetController = TextEditingController(
        text: widget.profile.monthlyBudget > 0 ? widget.profile.monthlyBudget.toString() : '');
    _avatar = widget.profile.avatar;
  }

  static const _avatars = ['👤', '😊', '🐱', '🐶', '🦊', '🐼', '🐨', '🐸', '🦄', '🐙', '🌸', '⭐', '💡', '🔥', '💎', '🎯'];

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入名称')));
      return;
    }
    setState(() => _saving = true);
    await UserService.save(UserProfile(
      name: name,
      avatar: _avatar,
      monthlyBudget: double.tryParse(_budgetController.text.trim()) ?? 0,
    ));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('编辑资料')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar picker
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(_avatar, style: const TextStyle(fontSize: 36)),
                ),
              ),
            ),
            AppSpacing.gapMd,
            Text('选择头像', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _avatars.map((e) {
                final selected = _avatar == e;
                return GestureDetector(
                  onTap: () => setState(() => _avatar = e),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.primaryContainer : null,
                      borderRadius: BorderRadius.circular(8),
                      border: selected ? Border.all(color: colorScheme.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                  ),
                );
              }).toList(),
            ),
            AppSpacing.gapXl,

            Text('名称', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: '你的称呼'),
            ),
            AppSpacing.gapXl,

            Text('月度预算（可选）', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            TextField(
              controller: _budgetController,
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
                    : const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
