import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../user/data/user_service.dart';
import '../../user/presentation/edit_profile_screen.dart';

/// "我的" tab: account-specific management and secondary bookkeeping tools.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile _profile = UserProfile();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await UserService.load();
    if (mounted) setState(() => _profile = p);
  }

  Future<void> _editProfile() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
    );
    if (result == true) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _ProfileHeader(profile: _profile, onEdit: _editProfile),
          AppSpacing.gapXl,
          const _SectionLabel('财务管理'),
          AppSpacing.gapSm,
          const _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.account_balance_wallet_rounded,
              label: '账户',
              subtitle: '管理现金、储蓄和信用账户',
              route: '/accounts',
            ),
            _SettingsItem(
              icon: Icons.savings_rounded,
              label: '预算',
              subtitle: '为支出分类设置月度目标',
              route: '/budgets',
            ),
            _SettingsItem(
              icon: Icons.event_note_rounded,
              label: '账单提醒',
              subtitle: '管理房租、订阅等固定支出',
              route: '/bills',
            ),
            _SettingsItem(
              icon: Icons.category_rounded,
              label: '分类管理',
              subtitle: '自定义收入和支出分类',
              route: '/category/manage',
            ),
          ]),
          AppSpacing.gapXl,
          const _SectionLabel('数据与工具'),
          AppSpacing.gapSm,
          const _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.ios_share_rounded,
              label: '数据导出',
              subtitle: '将记账记录导出为 CSV',
              route: '/settings/export',
            ),
          ]),
          AppSpacing.gapXl,
          const _SectionLabel('应用'),
          AppSpacing.gapSm,
          const _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.settings_rounded,
              label: '设置',
              subtitle: '数据存储、应用信息',
              route: '/settings',
            ),
          ]),
        ],
      ),
    );
  }
}

/// Hero card at the top: emoji avatar and profile shortcut.
class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;
  const _ProfileHeader({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: AppRadius.allLg,
      child: InkWell(
        borderRadius: AppRadius.allLg,
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  profile.avatar,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
              AppSpacing.gapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: AppTypography.titleMedium.copyWith(
                        color: cs.onPrimaryContainer,
                        fontSize: 18,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      '点击编辑个人资料',
                      style: AppTypography.bodySmall.copyWith(
                        color: cs.onPrimaryContainer
                            .withValues(alpha: AppColors.opacityHeroSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onPrimaryContainer
                    .withValues(alpha: AppColors.opacitySecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.allLg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 64),
                child: Divider(height: 1, color: cs.outlineVariant),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String route;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.route,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: AppColors.opacityMuted),
                borderRadius: AppRadius.allSm,
              ),
              child: Icon(icon, size: 20, color: cs.primary),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleSmall),
                  if (subtitle != null) ...[
                    AppSpacing.gapXs,
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurfaceVariant
                  .withValues(alpha: AppColors.opacitySecondary),
            ),
          ],
        ),
      ),
    );
  }
}
