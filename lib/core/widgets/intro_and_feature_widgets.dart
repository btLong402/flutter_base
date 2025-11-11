/// Flutter Intro Screen & Feature Intro Widgets
///
/// A comprehensive collection of reusable, customizable widgets for creating
/// onboarding experiences and feature walkthroughs in Flutter applications.
///
/// ## Packages Overview
///
/// ### 1. Intro Screen Package (`intro_screen/`)
/// Full-screen onboarding experiences with multiple pages, transitions, and indicators.
///
/// **Main Widgets:**
/// - `IntroScreenWidget` - Main intro screen with configurable pages
/// - `IntroPageWidget` - Single page with multiple layout options
/// - Page Indicators: `DotPageIndicator`, `LinePageIndicator`, `NumberPageIndicator`,
///   `ProgressBarPageIndicator`, `CircularProgressPageIndicator`
/// - `OnboardingStepWidget` - Animated step cards
/// - `TimelineStepWidget` - Vertical timeline for onboarding steps
/// - `ChecklistItemWidget` - Task checklist items
///
/// **Features:**
/// - 6 page layouts: standard, centered, imageTop, imageBackground, split, card
/// - 5 indicator styles: dots, lines, numbers, progressBar, custom
/// - Auto-play support
/// - Customizable transitions
/// - Multiple button alignment options
/// - Smooth animations
///
/// **Usage Example:**
/// ```dart
/// IntroScreenWidget(
///   pages: [
///     IntroPageData(
///       title: 'Welcome',
///       description: 'Get started with our app',
///       icon: Icons.rocket_launch,
///     ),
///     // Add more pages...
///   ],
///   onDone: () => Navigator.pushReplacementNamed(context, '/home'),
///   pageLayout: IntroPageLayout.standard,
///   pageIndicatorStyle: PageIndicatorStyle.dots,
/// )
/// ```
///
/// ### 2. Feature Intro Package (`feature_intro/`)
/// Contextual tooltips and highlights for showcasing specific UI elements.
///
/// **Main Widgets:**
/// - `FeatureIntroWidget` - Main feature intro with overlay and tooltips
/// - `FeatureTooltipWidget` - Customizable tooltip bubbles
/// - `SpotlightWidget` - Spotlight effect for highlighting features
/// - `TooltipBubbleWidget` - Simple tooltip with arrow
/// - `FeatureBadgeWidget` - "New" or "Updated" badges
///
/// **Features:**
/// - 4 highlight shapes: rectangle, circle, roundedRectangle, oval
/// - 6 tooltip positions: top, bottom, left, right, center, auto
/// - Pulse animations
/// - Auto-play support
/// - Tap/swipe to dismiss
/// - Step indicators
///
/// **Usage Example:**
/// ```dart
/// // Define features
/// final features = [
///   FeatureIntroData(
///     title: 'Search',
///     description: 'Find anything quickly',
///     targetKey: _searchButtonKey,
///     position: FeatureIntroPosition.bottom,
///     shape: FeatureIntroShape.roundedRectangle,
///   ),
///   // Add more features...
/// ];
///
/// // Show feature intro
/// showFeatureIntro(
///   context: context,
///   features: features,
///   config: FeatureIntroConfig(pulseAnimation: true),
/// );
/// ```
///
/// ## Architecture
///
/// ### Clean Separation of Concerns
/// ```
/// lib/core/widgets/
/// ├── intro_screen/
/// │   ├── intro_screen_models.dart       # Data models & configs
/// │   ├── intro_page_widget.dart         # Page layouts
/// │   ├── page_indicators.dart           # Indicator widgets
/// │   ├── intro_screen_widget.dart       # Main screen widget
/// │   ├── onboarding_components.dart     # Reusable components
/// │   └── intro_screen.dart              # Package export
/// └── feature_intro/
///     ├── feature_intro_models.dart      # Data models & configs
///     ├── feature_tooltip_widget.dart    # Tooltip widgets
///     ├── feature_highlight_painter.dart # Custom painter
///     ├── feature_intro_widget.dart      # Main intro widget
///     ├── contextual_hint_widgets.dart   # Hint widgets
///     └── feature_intro.dart             # Package export
/// ```
///
/// ### Design Principles
/// 1. **Reusability** - All widgets are modular and reusable
/// 2. **Configurability** - Extensive configuration options via models
/// 3. **Theme-aware** - Respects app theme (light/dark mode)
/// 4. **Responsive** - Adapts to different screen sizes
/// 5. **Animated** - Smooth transitions and animations
/// 6. **Accessible** - Keyboard navigation and screen reader support
///
/// ### UX Considerations
/// - **Progressive Disclosure** - Show information when needed
/// - **User Control** - Allow skip, back, and manual navigation
/// - **Visual Hierarchy** - Clear focus on important elements
/// - **Consistency** - Uniform styling across all components
/// - **Feedback** - Visual feedback for user interactions
///
/// ## Configuration Options
///
/// ### IntroScreenConfig
/// - `showSkipButton` - Show skip button
/// - `showBackButton` - Show back button
/// - `showNextButton` - Show next button
/// - `showDoneButton` - Show done button
/// - `showPageIndicator` - Show page indicator
/// - `autoPlayDuration` - Auto-advance delay
/// - `enableSwipeGesture` - Enable swipe to navigate
/// - `buttonsAlignment` - Button layout style
/// - `pageTransitionDuration` - Page transition speed
///
/// ### FeatureIntroConfig
/// - `overlayColor` - Overlay background color
/// - `pulseAnimation` - Enable pulse effect
/// - `showSkipButton` - Show skip option
/// - `showNextButton` - Show next option
/// - `enableTapToDismiss` - Tap to close
/// - `enableSwipeToDismiss` - Swipe to close
/// - `autoPlayDuration` - Auto-advance delay
/// - `showStepIndicator` - Show step counter
///
/// ## Examples Location
///
/// See `lib/features/demo_feature/` for complete examples:
/// - `intro_screen_example.dart` - Intro screen demos
/// - `feature_intro_example.dart` - Feature intro demos
/// - `onboarding_example.dart` - Onboarding components demos
/// - `intro_and_feature_demo.dart` - Comprehensive demo screen
///
/// ## Dependencies
///
/// Uses core theme files:
/// - `app_colors.dart` - Color palette
/// - `app_text_styles.dart` - Typography
/// - `app_inset.dart` - Spacing constants
///
/// ## Best Practices
///
/// 1. **Keep intro screens brief** - 3-5 pages maximum
/// 2. **Focus on value** - Show benefits, not just features
/// 3. **Use visuals** - Icons and images are more engaging than text
/// 4. **Allow skip** - Don't force users through entire intro
/// 5. **Show once** - Don't repeat intro on every app launch
/// 6. **Context matters** - Use feature intros when users need help
/// 7. **Test animations** - Ensure smooth performance on all devices
///
/// ## Customization Tips
///
/// ### Custom Page Layout
/// ```dart
/// IntroPageData(
///   title: 'Custom Page',
///   description: 'With custom widget',
///   customContent: YourCustomWidget(),
/// )
/// ```
///
/// ### Custom Page Indicator
/// ```dart
/// IntroScreenWidget(
///   customPageIndicator: (count, currentIndex) {
///     return YourCustomIndicator(count, currentIndex);
///   },
/// )
/// ```
///
/// ### Custom Tooltip
/// ```dart
/// FeatureIntroData(
///   customWidget: YourCustomTooltip(),
/// )
/// ```
///
/// ## Performance Notes
///
/// - Animations use `AnimationController` for smooth 60fps
/// - Images are loaded asynchronously
/// - Widgets use `const` constructors where possible
/// - Efficient rebuilds with `AnimatedBuilder` and `ValueListenableBuilder`
///
/// ## Accessibility
///
/// - All widgets support screen readers
/// - Proper semantic labels
/// - Sufficient color contrast ratios
/// - Touch targets meet minimum size requirements
/// - Keyboard navigation support
///
/// ---
///
/// **Version:** 1.0.0
/// **Author:** Flutter Team
/// **Last Updated:** 2025-11-10
library intro_and_feature_widgets;

// Export all packages
export 'package:code_base_riverpod/core/widgets/intro_screen/intro_screen.dart';
export 'package:code_base_riverpod/core/widgets/feature_intro/feature_intro.dart';
export 'package:code_base_riverpod/core/widgets/intro_screen/onboarding_components.dart';
export 'package:code_base_riverpod/core/widgets/feature_intro/contextual_hint_widgets.dart';
