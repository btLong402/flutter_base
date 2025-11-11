import 'package:flutter/material.dart';
import '../../../../core/theme/app_inset.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'intro_screen_example.dart';
import 'feature_intro_example.dart';
import 'onboarding_example.dart';

/// Comprehensive demo screen showcasing all intro and feature widgets
class IntroAndFeatureDemo extends StatelessWidget {
  const IntroAndFeatureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppInset.large),
      children: [
        _buildHeader(
          'Intro Screen Widgets',
          'Full-screen onboarding experiences',
        ),
        const SizedBox(height: AppInset.large),
        _buildDemoCard(
          context,
          'Standard Intro Screen',
          'Classic onboarding with multiple pages',
          Icons.swipe,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IntroScreenExample()),
          ),
        ),
        const SizedBox(height: AppInset.medium),
        _buildDemoCard(
          context,
          'Custom Layouts',
          'Different page layouts (card, centered, split)',
          Icons.view_carousel,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomLayoutIntroExample()),
          ),
        ),
        const SizedBox(height: AppInset.medium),
        _buildDemoCard(
          context,
          'Auto-play Intro',
          'Automatically advancing slides',
          Icons.play_arrow,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AutoPlayIntroExample()),
          ),
        ),
        const SizedBox(height: AppInset.medium),
        _buildDemoCard(
          context,
          'Page Indicators',
          'Various indicator styles (dots, lines, progress)',
          Icons.more_horiz,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PageIndicatorExample()),
          ),
        ),
        const SizedBox(height: AppInset.extraExtraLarge),
        _buildHeader(
          'Feature Intro Widgets',
          'Contextual tooltips highlighting UI elements',
        ),
        const SizedBox(height: AppInset.large),
        _buildDemoCard(
          context,
          'Feature Tour',
          'Interactive walkthrough of app features',
          Icons.tour,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeatureIntroExample()),
          ),
        ),
        const SizedBox(height: AppInset.medium),
        _buildDemoCard(
          context,
          'Custom Shapes & Positions',
          'Different highlight shapes and tooltip positions',
          Icons.highlight,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomFeatureIntroExample(),
            ),
          ),
        ),
        const SizedBox(height: AppInset.medium),
        _buildDemoCard(
          context,
          'Auto-play Feature Tour',
          'Automatically advancing feature highlights',
          Icons.auto_awesome,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AutoPlayFeatureIntroExample(),
            ),
          ),
        ),
        const SizedBox(height: AppInset.extraExtraLarge),
        _buildHeader(
          'Onboarding Components',
          'Reusable widgets for onboarding flows',
        ),
        const SizedBox(height: AppInset.large),
        _buildDemoCard(
          context,
          'Onboarding Steps & Timeline',
          'Step indicators, timelines, and checklists',
          Icons.checklist,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OnboardingComponentsExample(),
            ),
          ),
        ),
        const SizedBox(height: AppInset.medium),
        _buildDemoCard(
          context,
          'Contextual Hints',
          'Spotlights, tooltips, and feature badges',
          Icons.lightbulb,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContextualHintExample()),
          ),
        ),
        const SizedBox(height: AppInset.extraExtraLarge),
        _buildFeatureList(),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppInset.small),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppInset.large),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppInset.medium),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: AppInset.large),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppInset.small),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    return Container(
      padding: const EdgeInsets.all(AppInset.large),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppInset.medium),
              Text(
                'Key Features',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppInset.large),
          _buildFeatureItem(
            'Multiple page layouts (standard, centered, card, split)',
          ),
          _buildFeatureItem(
            'Customizable page indicators (dots, lines, progress bar)',
          ),
          _buildFeatureItem('Auto-play and manual navigation support'),
          _buildFeatureItem('Feature highlighting with tooltips'),
          _buildFeatureItem('Pulse animations and smooth transitions'),
          _buildFeatureItem('Timeline steps and checklists'),
          _buildFeatureItem('Contextual hints and badges'),
          _buildFeatureItem('Fully responsive and theme-aware'),
          _buildFeatureItem('Clean architecture with reusable components'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppInset.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: AppInset.medium),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
