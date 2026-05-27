import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/category_icon.dart';
import '../../category/domain/category_repository.dart';
import '../domain/transaction.dart';
import '../domain/transaction_repository.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  String _amount = '0';
  String _type = 'expense';
  String? _categoryId;
  String? _categoryName;
  int? _categoryIconCode;
  int? _categoryColorValue;
  DateTime _date = DateTime.now();
  final _noteController = TextEditingController();
  final _uuid = const Uuid();
  bool _hasDecimal = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryRepository().getByType(_type);
    if (cats.isNotEmpty && mounted) {
      setState(() {
        _categoryId = cats.first.id;
        _categoryName = cats.first.name;
        _categoryIconCode = cats.first.iconCodePoint;
        _categoryColorValue = cats.first.colorValue;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'back') {
        if (_amount.length > 1) {
          if (_amount.endsWith('.')) _hasDecimal = false;
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
          _hasDecimal = false;
        }
        return;
      }
      if (key == 'clear' || key == 'C') {
        _amount = '0';
        _hasDecimal = false;
        return;
      }
      if (key == '.') {
        if (_hasDecimal) return;
        _amount += '.';
        _hasDecimal = true;
        return;
      }
      // Numeric keys
      if (key == '00') {
        if (_amount == '0') return; // 00 on 0 does nothing
      }
      if (_amount == '0') {
        _amount = key;
      } else if (_amount.length < 10) {
        _amount += key;
      }
      // Prevent leading zeros like "05"
      if (_amount.startsWith('0') && _amount.length > 1 && !_amount.startsWith('0.')) {
        _amount = _amount.substring(1);
      }
    });
  }

  Future<void> _save() async {
    final parsedAmount = double.tryParse(_amount) ?? 0;
    // Allow amounts ending with "." like "123." → parse as-is (or warn)
    if (parsedAmount <= 0) {
      if (_amount.endsWith('.') || _amount == '0' || _amount == '0.' || _amount == '0.0' || _amount == '0.00') {
        // Amount not yet entered meaningfully
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    final now = DateTime.now();
    final tx = Transaction(
      id: _uuid.v4(),
      amount: parsedAmount,
      type: _type,
      categoryId: _categoryId!,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await TransactionRepository().insert(tx);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickCategory() async {
    final cats = await CategoryRepository().getByType(_type);
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.gapLg,
                Text(
                  '选择分类',
                  style: Theme.of(ctx).textTheme.headlineSmall,
                ),
                AppSpacing.gapLg,
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: cats.length,
                  itemBuilder: (_, i) {
                    final cat = cats[i];
                    final color = Color(cat.colorValue);
                    final selected = cat.id == _categoryId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _categoryId = cat.id;
                          _categoryName = cat.name;
                          _categoryIconCode = cat.iconCodePoint;
                          _categoryColorValue = cat.colorValue;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategoryIcon(
                            iconCodePoint: cat.iconCodePoint,
                            color: color,
                            size: selected ? 48 : 44,
                          ),
                          AppSpacing.gapXs,
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? color
                                  : colorScheme.onSurfaceVariant,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ),
                AppSpacing.gapLg,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpense = _type == 'expense';
    final accentColor = isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('记一笔'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Type toggle + amount display
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppSpacing.cardRadius + 8),
                ),
              ),
              child: Column(
                children: [
                  // Type toggle
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _type = 'expense';
                                _categoryId = null;
                                _categoryName = null;
                                _categoryIconCode = null;
                                _categoryColorValue = null;
                              });
                              _loadCategories();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isExpense
                                    ? AppColors.expense
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.buttonRadius,
                                ),
                              ),
                              child: Text(
                                '支出',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isExpense ? Colors.white : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _type = 'income';
                                _categoryId = null;
                                _categoryName = null;
                                _categoryIconCode = null;
                                _categoryColorValue = null;
                              });
                              _loadCategories();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isExpense
                                    ? AppColors.income
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.buttonRadius,
                                ),
                              ),
                              child: Text(
                                '收入',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isExpense ? Colors.white : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapXl,
                  // Amount display
                  Text(
                    '¥$_amount',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: accentColor,
                          fontSize: 40,
                        ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapMd,
            // Category & date row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      context,
                      icon: _categoryIconCode != null
                          ? IconData(_categoryIconCode!, fontFamily: 'MaterialIcons')
                          : Icons.category_outlined,
                      color: _categoryColorValue != null
                          ? Color(_categoryColorValue!)
                          : colorScheme.primary,
                      label: _categoryName ?? '选择分类',
                      onTap: _pickCategory,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: _buildInfoTile(
                      context,
                      icon: Icons.calendar_today_rounded,
                      color: colorScheme.secondary,
                      label: DateFormat('MM月dd日', 'zh_CN').format(_date),
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapSm,
            // Note
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: '添加备注...',
                  prefixIcon: Icon(Icons.edit_note_rounded, size: 20),
                ),
                maxLength: 200,
              ),
            ),
            AppSpacing.gapSm,
            // NumPad
            Expanded(
              child: _buildNumPad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    final colorScheme = Theme.of(context).colorScheme;
    final keys = [
      ['1', '2', '3', 'back'],
      ['4', '5', '6', 'clear'],
      ['7', '8', '9', '.'],
      ['00', '0', '', 'save'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: keys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                if (key == 'save') {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _type == 'expense'
                              ? AppColors.expense
                              : AppColors.income,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                        ),
                        child: const Text('保存', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                }
                if (key.isEmpty) return const Spacer();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _buildNumKey(key, colorScheme),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumKey(String key, ColorScheme colorScheme) {
    final isSpecial = key == 'back' || key == 'clear' || key == '.';

    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        decoration: BoxDecoration(
          color: isSpecial
              ? colorScheme.surfaceContainerLow
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        child: Center(
          child: key == 'back'
              ? const Icon(Icons.backspace_outlined, size: 22)
              : key == 'clear'
                  ? Text('C', style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ))
                  : key == '.'
                      ? Text('.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ))
                      : Text(
                          key,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
        ),
      ),
    );
  }
}
