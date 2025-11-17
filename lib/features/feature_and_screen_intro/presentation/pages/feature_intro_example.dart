import 'package:flutter/material.dart';
import '../../../../core/widgets/feature_intro/feature_intro.dart';
import '../../../../core/theme/app_inset.dart';

/// Example usage of FeatureIntroWidget
class FeatureIntroExample extends StatefulWidget {
  const FeatureIntroExample({super.key});

  @override
  State<FeatureIntroExample> createState() => _FeatureIntroExampleState();
}

class _FeatureIntroExampleState extends State<FeatureIntroExample> {
  final GlobalKey _button1Key = GlobalKey();
  final GlobalKey _button2Key = GlobalKey();
  final GlobalKey _button3Key = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  void _showFeatureIntro() {
    final features = [
      FeatureIntroData(
        title: 'Home Button',
        description: 'Tap here to return to the home screen at any time.',
        targetKey: _button1Key,
        icon: Icons.home,
        position: FeatureIntroPosition.bottom,
        shape: FeatureIntroShape.roundedRectangle,
      ),
      FeatureIntroData(
        title: 'Search Feature',
        description: 'Use the search to quickly find what you\'re looking for.',
        targetKey: _button2Key,
        icon: Icons.search,
        position: FeatureIntroPosition.bottom,
        shape: FeatureIntroShape.roundedRectangle,
      ),
      FeatureIntroData(
        title: 'Settings',
        description: 'Customize your app experience in the settings.',
        targetKey: _button3Key,
        icon: Icons.settings,
        position: FeatureIntroPosition.bottom,
        shape: FeatureIntroShape.roundedRectangle,
      ),
      FeatureIntroData(
        title: 'Add New Item',
        description: 'Tap this button to create something new!',
        targetKey: _fabKey,
        icon: Icons.add,
        position: FeatureIntroPosition.top,
        shape: FeatureIntroShape.circle,
      ),
    ];

    showFeatureIntro(
      context: context,
      features: features,
      config: const FeatureIntroConfig(
        pulseAnimation: true,
        showSkipButton: true,
        enableTapToDismiss: false,
      ),
      onComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature tour completed!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Intro Example'),
        actions: [
          IconButton(
            key: _button1Key,
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
          IconButton(
            key: _button2Key,
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            key: _button3Key,
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showFeatureIntro,
          child: const Text('Start Feature Tour'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Example with custom shapes and positions
class CustomFeatureIntroExample extends StatefulWidget {
  const CustomFeatureIntroExample({super.key});

  @override
  State<CustomFeatureIntroExample> createState() =>
      _CustomFeatureIntroExampleState();
}

class _CustomFeatureIntroExampleState extends State<CustomFeatureIntroExample> {
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _listKey = GlobalKey();

  void _showTour() {
    final features = [
      FeatureIntroData(
        title: 'Your Profile',
        description: 'View and edit your profile information here.',
        targetKey: _profileKey,
        position: FeatureIntroPosition.bottom,
        shape: FeatureIntroShape.circle,
        highlightColor: Colors.blue,
      ),
      FeatureIntroData(
        title: 'Featured Content',
        description: 'Discover trending and recommended content.',
        targetKey: _cardKey,
        position: FeatureIntroPosition.auto,
        shape: FeatureIntroShape.roundedRectangle,
        highlightColor: Colors.purple,
      ),
      FeatureIntroData(
        title: 'Your Activity',
        description: 'Track your recent activity and history.',
        targetKey: _listKey,
        position: FeatureIntroPosition.top,
        shape: FeatureIntroShape.rectangle,
        highlightColor: Colors.green,
      ),
    ];

    showFeatureIntro(
      context: context,
      features: features,
      config: const FeatureIntroConfig(
        pulseAnimation: true,
        showStepIndicator: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Feature Intro'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              key: _profileKey,
              child: const Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppInset.large),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showTour,
              child: const Text('Start Custom Tour'),
            ),
            const SizedBox(height: AppInset.extraLarge),
            Card(
              key: _cardKey,
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(AppInset.large),
                child: const Center(child: Text('Featured Card')),
              ),
            ),
            const SizedBox(height: AppInset.extraLarge),
            Container(
              key: _listKey,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Activity ${index + 1}'),
                    subtitle: const Text('Recent item'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example with auto-play feature intro
class AutoPlayFeatureIntroExample extends StatefulWidget {
  const AutoPlayFeatureIntroExample({super.key});

  @override
  State<AutoPlayFeatureIntroExample> createState() =>
      _AutoPlayFeatureIntroExampleState();
}

class _AutoPlayFeatureIntroExampleState
    extends State<AutoPlayFeatureIntroExample> {
  final GlobalKey _feature1 = GlobalKey();
  final GlobalKey _feature2 = GlobalKey();
  final GlobalKey _feature3 = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Auto-show feature intro after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        _showAutoPlayTour();
      });
    });
  }

  void _showAutoPlayTour() {
    final features = [
      FeatureIntroData(
        title: 'Feature 1',
        description: 'This tour will automatically advance.',
        targetKey: _feature1,
        position: FeatureIntroPosition.bottom,
      ),
      FeatureIntroData(
        title: 'Feature 2',
        description: 'Wait for it...',
        targetKey: _feature2,
        position: FeatureIntroPosition.auto,
      ),
      FeatureIntroData(
        title: 'Feature 3',
        description: 'You can still skip or navigate manually.',
        targetKey: _feature3,
        position: FeatureIntroPosition.top,
      ),
    ];

    showFeatureIntro(
      context: context,
      features: features,
      config: const FeatureIntroConfig(
        autoPlayDuration: Duration(seconds: 3),
        pulseAnimation: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-play Feature Intro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              key: _feature1,
              onPressed: () {},
              child: const Text('Feature 1'),
            ),
            ElevatedButton(
              key: _feature2,
              onPressed: () {},
              child: const Text('Feature 2'),
            ),
            ElevatedButton(
              key: _feature3,
              onPressed: () {},
              child: const Text('Feature 3'),
            ),
          ],
        ),
      ),
    );
  }
}
