import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/database/storage_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageMode _mode = StorageMode.local;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final mode = await StorageConfig.getMode();
    if (mounted) setState(() => _mode = mode);
  }

  Future<void> _switchMode(StorageMode mode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('切换数据存储'),
        content: Text(mode == StorageMode.remote
            ? '切换到远程数据库？\n\n需要确保服务器正在运行。'
            : '切换到本地存储？\n\n数据将保存在手机本地。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认')),
        ],
      ),
    );
    if (confirmed != true) return;

    await DatabaseHelper.instance.switchMode(mode);
    if (mounted) {
      setState(() => _mode = mode);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mode == StorageMode.remote ? '已切换到远程数据库' : '已切换到本地存储')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Storage mode
          _sectionTitle(context, '数据存储'),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (_mode == StorageMode.remote ? AppColors.expense : AppColors.income).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Icon(
                _mode == StorageMode.remote ? Icons.cloud_done_outlined : Icons.phone_android_outlined,
                color: _mode == StorageMode.remote ? AppColors.expense : AppColors.income,
              ),
            ),
            title: const Text('数据库'),
            subtitle: Text(_mode == StorageMode.remote ? '远程服务器' : '本地存储'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _switchMode(
              _mode == StorageMode.remote ? StorageMode.local : StorageMode.remote,
            ),
          ),

          const Divider(indent: 72),
          const SizedBox(height: AppSpacing.lg),

          // Export section
          _sectionTitle(context, '数据'),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Icon(Icons.file_download_outlined, color: AppColors.primary),
            ),
            title: const Text('导出数据'),
            subtitle: const Text('导出为 CSV 格式'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/export'),
          ),

          const Divider(indent: 72),

          // Category management
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Icon(Icons.category_outlined, color: colorScheme.secondary),
            ),
            title: const Text('分类管理'),
            subtitle: const Text('添加、编辑或删除收支分类'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/category/manage'),
          ),

          const SizedBox(height: AppSpacing.xl),

          // About section
          _sectionTitle(context, '关于'),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Icon(Icons.info_outline, color: colorScheme.primary),
            ),
            title: const Text('关于钱记'),
            subtitle: const Text('版本 1.0.0'),
          ),

          const Divider(indent: 72),

          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Icon(Icons.favorite, color: AppColors.expense, size: 20),
            ),
            title: const Text('用心记账，好好生活'),
            subtitle: const Text('Made with love'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1,
            ),
      ),
    );
  }
}
