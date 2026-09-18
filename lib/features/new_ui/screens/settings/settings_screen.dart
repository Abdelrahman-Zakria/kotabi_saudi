import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';

import 'package:kotabi_saudi/core/new_ui/app_colors.dart';
import 'package:kotabi_saudi/core/new_ui/strings.dart';
import 'package:kotabi_saudi/core/new_ui/app_constants.dart';
import 'package:kotabi_saudi/core/providers/settings_provider.dart';
import 'package:kotabi_saudi/core/providers/favorites_provider.dart';
import 'package:kotabi_saudi/core/services/scraping_service.dart';
import 'package:kotabi_saudi/core/services/iap_service.dart';
import 'package:kotabi_saudi/core/new_ui/helpers.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/features/home/presentation/screens/notifications/notifications_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              //const _SettingsHeaderCard(),
              const SizedBox(height: 16),
              StreamBuilder<bool>(
                stream: sl<IapService>().isLoadingStream,
                initialData: false,
                builder: (context, loadingSnapshot) {
                  final isLoading = loadingSnapshot.data ?? false;

                  return StreamBuilder<bool>(
                    stream: sl<IapService>().adFreeStatusStream,
                    initialData: sl<IapService>().isAdFree,
                    builder: (context, snapshot) {
                      final isPremium = snapshot.data ?? false;
                      return _SettingsSection(
                        title: 'النسخة الاحترافية',
                        children: [
                          Stack(
                            children: [
                              _SettingsTile(
                                icon: Icons.auto_awesome_rounded,
                                title: 'إزالة الإعلانات',
                                subtitle: isPremium 
                                  ? 'أنت تستمتع بالنسخة الكاملة بدون إعلانات' 
                                  : 'تخلص من الإعلانات المزعجة وادعم التطبيق',
                                color: const Color(0xFFD6A64F),
                                onTap: (isPremium || isLoading) ? null : () => sl<IapService>().buyAdRemoval(),
                                trailing: isPremium 
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
                                  : null,
                              ),
                              if (isLoading && !isPremium)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (!isPremium) ...[
                            const Divider(height: 1, indent: 56),
                            _SettingsTile(
                              icon: Icons.restore_rounded,
                              title: 'استعادة المشتريات',
                              subtitle: isLoading ? 'جاري الاستعادة...' : 'إذا قمت بالشراء مسبقاً، استعده من هنا',
                              color: const Color(0xFF6B7280),
                              onTap: isLoading ? null : () => sl<IapService>().restorePurchases(),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'التنبيهات',
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'تلقي الإشعارات',
                    subtitle: 'تفعيل أو تعطيل التنبيهات على هذا الجهاز',
                    color: const Color(0xFF6366F1),
                    trailing: Switch.adaptive(
                      value: settingsProvider.notificationsEnabled,
                      onChanged: settingsProvider.setNotificationsEnabled,
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.history_rounded,
                    title: 'سجل الإشعارات',
                    subtitle: 'عرض الإشعارات التي وصلتك مؤخراً',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              // _SettingsSection(
              //   title: 'عرض الكتب',
              //   children: [
              //     _SettingsTile(
              //       icon: Icons.text_fields_rounded,
              //       title: AppStrings.fontSize,
              //       subtitle: _getFontSizeLabel(settingsProvider.fontSize),
              //       color: AppColors.primary,
              //       trailing: _FontSizeSelector(
              //         currentSize: settingsProvider.fontSize,
              //         onChanged: settingsProvider.setFontSize,
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'البيانات والتخزين',
                children: [
                  _SettingsTile(
                    icon: Icons.cached_rounded,
                    title: AppStrings.clearCache,
                    subtitle: 'مسح البيانات المحفوظة مؤقتاً',
                    color: AppColors.primary,
                    onTap: () => _clearCache(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'مسح المفضلة',
                    subtitle: 'حذف جميع الكتب المحفوظة في المفضلة',
                    color: const Color(0xFFE05C6B),
                    onTap: () => _clearFavorites(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'التطبيق والدعم',
                children: [
                  _SettingsTile(
                    icon: Icons.star_rounded,
                    title: AppStrings.rateApp,
                    subtitle: 'تقييمك يساعدنا على التحسين المستمر',
                    color: const Color(0xFFF59E0B),
                    onTap: () => _showNativeRateDialog(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.share_rounded,
                    title: AppStrings.shareApp,
                    subtitle: 'شارك التطبيق مع أصدقائك',
                    color: AppColors.primary,
                    onTap: () => _shareApp(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: Icons.policy_rounded,
                    title: 'سياسة الخصوصية',
                    subtitle: 'اطلع على كيفية حماية بياناتك',
                    color: const Color(0xFF6366F1),
                    onTap: () => _launchUrl('https://www.termsfeed.com/live/fa68a389-161c-4773-b7ea-c0908ae0389c'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'الإصدار ${AppConstants.appVersion}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  String _getFontSizeLabel(double size) {
    if (size <= 0.85) return 'صغير';
    if (size <= 1.0) return 'متوسط';
    return 'كبير';
  }

  void _clearCache(BuildContext context) {
    ScrapingService().clearCache();
    AppHelpers.showSnackBar(context, 'تم مسح التخزين المؤقت');
  }

  void _clearFavorites(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'مسح المفضلة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'هل أنت متأكد من مسح جميع الكتب المفضلة؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<FavoritesProvider>().clearFavorites();
                    Navigator.pop(ctx);
                    AppHelpers.showSnackBar(context, 'تم مسح المفضلة');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE05C6B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'مسح',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    const String text = 'تطبيق كتبي المدرسية - مكتبتك المدرسية الرقمية للمناهج السعودية. حمله الآن: ${AppConstants.appStoreLink}';
    Share.share(text);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showNativeRateDialog(BuildContext context) async {
    final inAppReview = InAppReview.instance;

    try {
      final isAvailable = await inAppReview.isAvailable();

      if (isAvailable) {
        await inAppReview.requestReview();
        return;
      } else {
        // Fallback to app store link
        _launchUrl(AppConstants.appStoreLink);
      }
    } catch (_) {
      _launchUrl(AppConstants.appStoreLink);
    }
  }
}

class _SettingsHeaderCard extends StatelessWidget {
  const _SettingsHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings_suggest_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات أنظف وأوضح',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'عدّل طريقة العرض، نظّف البيانات، وقيّم التطبيق من نافذة iOS الأصلية.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  (onTap != null
                      ? const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textLight,
                        )
                      : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontSizeSelector extends StatelessWidget {
  final double currentSize;
  final ValueChanged<double> onChanged;

  const _FontSizeSelector({
    required this.currentSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SizeButton(
          label: 'ص',
          size: 0.8,
          currentSize: currentSize,
          onChanged: onChanged,
        ),
        const SizedBox(width: 4),
        _SizeButton(
          label: 'م',
          size: 1.0,
          currentSize: currentSize,
          onChanged: onChanged,
        ),
        const SizedBox(width: 4),
        _SizeButton(
          label: 'ك',
          size: 1.2,
          currentSize: currentSize,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final double size;
  final double currentSize;
  final ValueChanged<double> onChanged;

  const _SizeButton({
    required this.label,
    required this.size,
    required this.currentSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = (currentSize - size).abs() < 0.05;

    return GestureDetector(
      onTap: () => onChanged(size),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
