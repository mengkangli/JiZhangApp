import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_icon_data.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  String _type = 'expense';
  int _selectedIconCode = 0xe561; // restaurant
  int _selectedColorValue = 0xFFD4914A;
  final _uuid = const Uuid();

  static const _icons = [
    0xe561,
    0xe531,
    0xe54f,
    0xe02c,
    0xe328,
    0xe548,
    0xe227,
    0xe0af,
    0xe0f2,
    0xe31b,
    0xe80e,
    0xe8b0,
    0xe0be,
    0xe30d,
    0xe553,
    0xe04b,
    0xe54e,
    0xe57a,
    0xe050,
    0xe53a,
    0xe30a,
    0xe059,
    0xe3b3,
    0xe043,
    0xe578,
    0xe32a,
    0xe0f8,
    0xe552,
    0xe8b8,
    0xe321,
    0xe234,
    0xe7f1,
  ];

  static const _presetColors = [
    Color(0xFFD4914A),
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFF8E24AA),
    Color(0xFF5E35B1),
    Color(0xFF3949AB),
    Color(0xFF1E88E5),
    Color(0xFF039BE5),
    Color(0xFF00ACC1),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFF7CB342),
    Color(0xFFF4511E),
    Color(0xFF795548),
    Color(0xFF546E7A),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入分类名称')),
      );
      return;
    }

    final now = DateTime.now();
    final category = Category(
      id: _uuid.v4(),
      name: name,
      iconCodePoint: _selectedIconCode,
      colorValue: _selectedColorValue,
      type: _type,
      sortOrder: 99,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    await CategoryRepository().insert(category);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加分类'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            Text('类型', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('支出')),
                ButtonSegment(value: 'income', label: Text('收入')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return _type == 'income'
                        ? AppColors.incomeBg
                        : AppColors.expenseBg;
                  }
                  return null;
                }),
              ),
            ),
            AppSpacing.gapXl,

            // Name
            Text('名称', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '例如: 外卖',
              ),
            ),
            AppSpacing.gapXl,

            // Color picker
            Text('颜色', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _presetColors.map((color) {
                final selected = _selectedColorValue == color.toARGB32();
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColorValue = color.toARGB32()),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: colorScheme.onSurface, width: 3)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            AppSpacing.gapXl,

            // Icon picker
            Text('图标', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.gapSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _icons.map((code) {
                final selected = _selectedIconCode == code;
                final c = Color(_selectedColorValue);
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconCode = code),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? c.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: selected ? Border.all(color: c, width: 2) : null,
                    ),
                    child: Icon(
                      AppIconData.fromCodePoint(code),
                      color: selected ? c : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
