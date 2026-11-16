import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:roadlink/shared/widgets/roadlink_button.dart';
import 'package:roadlink/shared/widgets/roadlink_status_badge.dart';

/// Settings screen allowing the user to toggle between Light and Dark themes,
/// alongside the "Brake inspection" theme preview card from Figma board 02.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ResponsiveCenter(
      maxContentWidth: 720,
      padding: Responsive.horizontalPadding(context).copyWith(
        top: AppSpacing.s24,
        bottom: AppSpacing.s24,
      ),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final isDark = themeMode == ThemeMode.dark ||
              (themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          return ListView(
            children: [
              Text(
                'Appearance',
                style: AppTypography.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Theme'),
                      subtitle: Text(
                        isDark
                            ? 'Dark mode is currently active'
                            : 'Light mode is currently active',
                      ),
                      value: isDark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme(value);
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(AppLayout.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Theme Mode',
                            style: AppTypography.label.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          SegmentedButton<ThemeMode>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                label: Text('Light'),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                label: Text('Dark'),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.system,
                                label: Text('System'),
                              ),
                            ],
                            selected: <ThemeMode>{themeMode},
                            onSelectionChanged: (Set<ThemeMode> selection) {
                              context
                                  .read<ThemeCubit>()
                                  .setThemeMode(selection.first);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppLayout.sectionGap),
              Text(
                'Theme preview',
                style: AppTypography.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              const _ServicePreviewCard(),
              const SizedBox(height: AppLayout.sectionGap),
              Text(
                'Sky Blue palette sample',
                style: AppTypography.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.s12),
              const _SkyBlueSampleCard(),
            ],
          );
        },
      ),
    );
  }
}

/// Sample card from Figma board 02 ("Same content. Different theme.").
/// Uses only semantic tokens from [RoadlinkColors] and shared Roadlink widgets.
class _ServicePreviewCard extends StatelessWidget {
  const _ServicePreviewCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.surfaceRaised,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(color: c.borderDefault),
                  ),
                  child: Icon(
                    Icons.build_outlined,
                    size: 18,
                    color: c.actionAccent,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brake inspection',
                        style: AppTypography.titleOf(context).copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      Text(
                        'Avondale, Harare',
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const RoadlinkStatusBadge(
                  label: 'Request sent',
                  status: RoadlinkStatus.success,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Review your request details before choosing a service provider.',
              style: AppTypography.bodyOf(context).copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RoadlinkButton(
                  label: 'View details',
                  trailingIcon: Icons.arrow_forward,
                  variant: RoadlinkButtonVariant.link,
                  onPressed: () {},
                ),
                RoadlinkButton(
                  label: 'Find services',
                  variant: RoadlinkButtonVariant.primary,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkyBlueSampleCard extends StatelessWidget {
  const _SkyBlueSampleCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const swatches = [
      ('sky50', AppPalette.blue50),
      ('sky100', AppPalette.blue100),
      ('sky400', AppPalette.blue400),
      ('sky500', AppPalette.blue500),
      ('sky600', AppPalette.blue600),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s12,
              children: [
                for (final swatch in swatches)
                  Column(
                    children: [
                      Container(
                        width: 44,
                        height: 32,
                        decoration: BoxDecoration(
                          color: swatch.$2,
                          borderRadius: AppRadius.smAll,
                          border: Border.all(color: c.borderDefault),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        swatch.$1,
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: c.infoBackground,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: AppPalette.blue500.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: c.infoForeground),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      'Live GPS & verified provider badges look crisp in Sky Blue paired with Navy & Orange.',
                      style: AppTypography.caption.copyWith(
                        color: c.infoForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s8,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.buttonBlue,
                    foregroundColor: AppPalette.neutral0,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  child: const Text('Sky Blue CTA'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPalette.blue500,
                    side: const BorderSide(color: AppPalette.blue500),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  child: const Text('Sky Blue Outline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
