import 'package:flutter/material.dart';
import '../../../../core/widgets/intro_screen/onboarding_components.dart';
import '../../../../core/widgets/feature_intro/contextual_hint_widgets.dart';
import '../../../../core/theme/app_inset.dart';

/// Example of using various onboarding components
class OnboardingComponentsExample extends StatefulWidget {
  const OnboardingComponentsExample({super.key});

  @override
  State<OnboardingComponentsExample> createState() =>
      _OnboardingComponentsExampleState();
}

class _OnboardingComponentsExampleState
    extends State<OnboardingComponentsExample> {
  int _activeStep = 0;
  final List<bool> _checklistItems = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding Components'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppInset.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Onboarding Steps
            const Text(
              'Onboarding Steps',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppInset.large),
            Row(
              children: [
                Expanded(
                  child: OnboardingStepWidget(
                    icon: Icons.person_add,
                    title: 'Create Account',
                    description: 'Sign up to get started',
                    isActive: _activeStep == 0,
                    onTap: () => setState(() => _activeStep = 0),
                  ),
                ),
                const SizedBox(width: AppInset.medium),
                Expanded(
                  child: OnboardingStepWidget(
                    icon: Icons.settings,
                    title: 'Setup Profile',
                    description: 'Customize your experience',
                    isActive: _activeStep == 1,
                    onTap: () => setState(() => _activeStep = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppInset.large),
            Row(
              children: [
                Expanded(
                  child: OnboardingStepWidget(
                    icon: Icons.explore,
                    title: 'Explore',
                    description: 'Discover features',
                    isActive: _activeStep == 2,
                    onTap: () => setState(() => _activeStep = 2),
                  ),
                ),
                const SizedBox(width: AppInset.medium),
                Expanded(
                  child: OnboardingStepWidget(
                    icon: Icons.done_all,
                    title: 'Get Started',
                    description: 'Begin your journey',
                    isActive: _activeStep == 3,
                    onTap: () => setState(() => _activeStep = 3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppInset.extraExtraLarge),

            // Timeline Steps
            const Text(
              'Timeline Steps',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppInset.large),
            TimelineStepWidget(
              title: 'Welcome',
              description: 'Learn the basics of the app',
              stepNumber: 1,
              isCompleted: true,
              icon: Icons.waving_hand,
            ),
            TimelineStepWidget(
              title: 'Setup',
              description: 'Configure your preferences',
              stepNumber: 2,
              isActive: true,
              icon: Icons.build,
            ),
            TimelineStepWidget(
              title: 'Explore',
              description: 'Try out key features',
              stepNumber: 3,
              icon: Icons.explore,
            ),
            TimelineStepWidget(
              title: 'Complete',
              description: 'You\'re all set!',
              stepNumber: 4,
              isLast: true,
              icon: Icons.celebration,
            ),

            const SizedBox(height: AppInset.extraExtraLarge),

            // Checklist Items
            const Text(
              'Onboarding Checklist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppInset.large),
            ChecklistItemWidget(
              title: 'Complete your profile',
              description: 'Add a photo and bio',
              isCompleted: _checklistItems[0],
              icon: Icons.person,
              onTap: () => setState(() => _checklistItems[0] = !_checklistItems[0]),
            ),
            const SizedBox(height: AppInset.medium),
            ChecklistItemWidget(
              title: 'Connect accounts',
              description: 'Link your social media',
              isCompleted: _checklistItems[1],
              icon: Icons.link,
              onTap: () => setState(() => _checklistItems[1] = !_checklistItems[1]),
            ),
            const SizedBox(height: AppInset.medium),
            ChecklistItemWidget(
              title: 'Invite friends',
              description: 'Share the app with 3 friends',
              isCompleted: _checklistItems[2],
              icon: Icons.group_add,
              onTap: () => setState(() => _checklistItems[2] = !_checklistItems[2]),
            ),
            const SizedBox(height: AppInset.medium),
            ChecklistItemWidget(
              title: 'Enable notifications',
              description: 'Stay updated with alerts',
              isCompleted: _checklistItems[3],
              icon: Icons.notifications,
              onTap: () => setState(() => _checklistItems[3] = !_checklistItems[3]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of contextual hint widgets
class ContextualHintExample extends StatefulWidget {
  const ContextualHintExample({super.key});

  @override
  State<ContextualHintExample> createState() => _ContextualHintExampleState();
}

class _ContextualHintExampleState extends State<ContextualHintExample> {
  bool _showSpotlight = false;
  bool _showBadges = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contextual Hints'),
      ),
      body: _showSpotlight
          ? SpotlightWidget(
              title: 'New Feature!',
              message:
                  'Check out our new dashboard with improved analytics and insights.',
              onDismiss: () => setState(() => _showSpotlight = false),
              child: _buildContent(),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppInset.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => setState(() => _showSpotlight = true),
            child: const Text('Show Spotlight'),
          ),
          const SizedBox(height: AppInset.large),
          ElevatedButton(
            onPressed: () => setState(() => _showBadges = !_showBadges),
            child: Text(_showBadges ? 'Hide Badges' : 'Show Badges'),
          ),
          const SizedBox(height: AppInset.extraExtraLarge),

          // Tooltip bubbles
          const Center(
            child: Column(
              children: [
                TooltipBubbleWidget(
                  message: 'Tap here to get started!',
                  arrowPosition: TooltipArrowPosition.bottom,
                ),
                SizedBox(height: AppInset.extraLarge),
                TooltipBubbleWidget(
                  message: 'This feature is new',
                  arrowPosition: TooltipArrowPosition.top,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppInset.extraExtraLarge),

          // Feature badges
          const Text(
            'Features with Badges',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppInset.large),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FeatureBadgeWidget(
                badgeText: 'New',
                showBadge: _showBadges,
                position: BadgePosition.topRight,
                child: _buildFeatureCard('Analytics', Icons.analytics),
              ),
              FeatureBadgeWidget(
                badgeText: 'Beta',
                badgeColor: Colors.orange,
                showBadge: _showBadges,
                position: BadgePosition.topRight,
                child: _buildFeatureCard('AI Chat', Icons.chat),
              ),
            ],
          ),
          const SizedBox(height: AppInset.large),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FeatureBadgeWidget(
                badgeText: 'Updated',
                badgeColor: Colors.blue,
                showBadge: _showBadges,
                position: BadgePosition.topLeft,
                child: _buildFeatureCard('Calendar', Icons.calendar_month),
              ),
              FeatureBadgeWidget(
                badgeText: 'Pro',
                badgeColor: Colors.purple,
                showBadge: _showBadges,
                position: BadgePosition.bottomRight,
                child: _buildFeatureCard('Export', Icons.download),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon) {
    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(AppInset.large),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: AppInset.medium),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
