import 'package:code_base_riverpod/core/transitions/custom_transition.dart';
import 'package:code_base_riverpod/core/transitions/platform_adaptive.dart';
import 'package:code_base_riverpod/core/transitions/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('transition presets', () {
    test('fade preset exposes tuned durations', () {
      final transition = transitionForPreset(TransitionPreset.fade);
      expect(transition.duration, const Duration(milliseconds: 220));
      expect(transition.reverseDuration, const Duration(milliseconds: 180));
    });

    test('modal sheet is non-opaque and compositor friendly', () {
      final transition = transitionForPreset(TransitionPreset.modalSheet);
      expect(transition.opaque, isFalse);
      expect(transition.useCompositor, isTrue);
    });
  });

  testWidgets('reduced motion disables animations', (tester) async {
    final transition = transitionForPreset(TransitionPreset.fadeScale);
    late CustomRouteTransition resolved;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              resolved = PlatformAdaptiveTransitions.resolveAccessibility(
                context,
                transition,
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(resolved.duration, Duration.zero);
    final builder = resolved.toBuilder();
    final widget = builder(
      tester.element(find.byType(SizedBox)),
      const AlwaysStoppedAnimation(1.0),
      const AlwaysStoppedAnimation(0.0),
      const SizedBox(),
    );
    expect(widget, isA<SizedBox>());
  });

  test('composeTransitions wraps primitives in order', () {
    int fadeCalls = 0;
    int slideCalls = 0;

    final builder = composeTransitions([
      (context, animation, secondary, child) {
        fadeCalls++;
        return child;
      },
      (context, animation, secondary, child) {
        slideCalls++;
        return child;
      },
    ]);

    final result = builder(
      _MockBuildContext(),
      const AlwaysStoppedAnimation(1.0),
      const AlwaysStoppedAnimation(0.0),
      const SizedBox(),
    );

    expect(result, isA<SizedBox>());
    expect(fadeCalls, 1);
    expect(slideCalls, 1);
  });

  test('toBuilder applies repaint boundary when requested', () {
    final transition = CustomRouteTransition(
      useCompositor: true,
      primitives: [TransitionPrimitives.fade()],
    );

    final widget = transition.toBuilder().call(
      _MockBuildContext(),
      const AlwaysStoppedAnimation(1.0),
      const AlwaysStoppedAnimation(0.0),
      const SizedBox(),
    );

    expect(widget, isA<RepaintBoundary>());
  });
}

class _MockBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
