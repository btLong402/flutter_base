import 'package:flutter/material.dart';
import '../../../../core/widgets/intro_screen/intro_screen.dart';

/// Example usage of IntroScreenWidget
class IntroScreenExample extends StatelessWidget {
  const IntroScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const IntroPageData(
        title: 'Welcome to Our App',
        description:
            'Discover amazing features that will enhance your productivity and make your life easier.',
        icon: Icons.rocket_launch,
      ),
      const IntroPageData(
        title: 'Stay Organized',
        description:
            'Keep track of all your tasks and projects in one place. Never miss a deadline again.',
        icon: Icons.calendar_today,
      ),
      const IntroPageData(
        title: 'Collaborate Seamlessly',
        description:
            'Work together with your team in real-time. Share ideas and make progress faster.',
        icon: Icons.people,
      ),
      const IntroPageData(
        title: 'Secure & Private',
        description:
            'Your data is protected with enterprise-grade security. We take your privacy seriously.',
        icon: Icons.security,
      ),
    ];

    return IntroScreenWidget(
      pages: pages,
      onDone: () {
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/home');
      },
      config: const IntroScreenConfig(
        showSkipButton: true,
        showPageIndicator: true,
        buttonsAlignment: ButtonsAlignment.bottomSpaced,
      ),
      pageIndicatorStyle: PageIndicatorStyle.dots,
      pageLayout: IntroPageLayout.standard,
    );
  }
}

/// Example with custom layouts
class CustomLayoutIntroExample extends StatelessWidget {
  const CustomLayoutIntroExample({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      IntroPageData(
        title: 'Image Top Layout',
        description: 'Beautiful image at the top with text below',
        image: 'assets/images/intro1.png', // Replace with your asset
        icon: Icons.image,
        backgroundColor: Colors.blue.shade50,
      ),
      IntroPageData(
        title: 'Card Layout',
        description: 'Content displayed in an elegant card',
        icon: Icons.card_membership,
        backgroundColor: Colors.purple.shade50,
      ),
      IntroPageData(
        title: 'Centered Layout',
        description: 'Everything centered for focus',
        icon: Icons.center_focus_strong,
        backgroundColor: Colors.green.shade50,
      ),
    ];

    return IntroScreenWidget(
      pages: pages,
      onDone: () => Navigator.of(context).pop(),
      pageLayout: IntroPageLayout.card,
      pageIndicatorStyle: PageIndicatorStyle.progressBar,
      config: const IntroScreenConfig(
        buttonsAlignment: ButtonsAlignment.bottomCenter,
        showPageIndicator: true,
      ),
    );
  }
}

/// Example with auto-play
class AutoPlayIntroExample extends StatelessWidget {
  const AutoPlayIntroExample({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const IntroPageData(
        title: 'Auto-playing Intro',
        description: 'This intro automatically advances every 3 seconds',
        icon: Icons.timer,
      ),
      const IntroPageData(
        title: 'Second Page',
        description: 'Watch as it transitions smoothly',
        icon: Icons.arrow_forward,
      ),
      const IntroPageData(
        title: 'Final Page',
        description: 'You can still navigate manually',
        icon: Icons.done,
      ),
    ];

    return IntroScreenWidget(
      pages: pages,
      onDone: () => Navigator.of(context).pop(),
      config: const IntroScreenConfig(
        autoPlayDuration: Duration(seconds: 3),
        showSkipButton: true,
      ),
      pageIndicatorStyle: PageIndicatorStyle.numbers,
    );
  }
}

/// Example with different page indicators
class PageIndicatorExample extends StatefulWidget {
  const PageIndicatorExample({super.key});

  @override
  State<PageIndicatorExample> createState() => _PageIndicatorExampleState();
}

class _PageIndicatorExampleState extends State<PageIndicatorExample> {
  PageIndicatorStyle _currentStyle = PageIndicatorStyle.dots;

  final pages = const [
    IntroPageData(
      title: 'Dots Indicator',
      description: 'Classic dot style indicator',
      icon: Icons.circle,
    ),
    IntroPageData(
      title: 'Lines Indicator',
      description: 'Modern line style indicator',
      icon: Icons.remove,
    ),
    IntroPageData(
      title: 'Progress Bar',
      description: 'Linear progress bar indicator',
      icon: Icons.linear_scale,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Indicators'),
        actions: [
          PopupMenuButton<PageIndicatorStyle>(
            onSelected: (style) => setState(() => _currentStyle = style),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: PageIndicatorStyle.dots,
                child: Text('Dots'),
              ),
              const PopupMenuItem(
                value: PageIndicatorStyle.lines,
                child: Text('Lines'),
              ),
              const PopupMenuItem(
                value: PageIndicatorStyle.progressBar,
                child: Text('Progress Bar'),
              ),
              const PopupMenuItem(
                value: PageIndicatorStyle.numbers,
                child: Text('Numbers'),
              ),
              const PopupMenuItem(
                value: PageIndicatorStyle.custom,
                child: Text('Circular'),
              ),
            ],
          ),
        ],
      ),
      body: IntroScreenWidget(
        pages: pages,
        onDone: () => Navigator.of(context).pop(),
        pageIndicatorStyle: _currentStyle,
      ),
    );
  }
}
