# Hyper Grid Benchmarks

The `benchmarks/` folder hosts micro-benchmarks for profiling layout throughput.

1. Launch in profile mode:
   ```sh
   flutter run --profile example/lib/main.dart
   ```
2. Open the Flutter DevTools performance page and enable the "Widget build" timeline events.
3. Interact with the masonry and auto-placement tabs to capture frame times across 1k+ items.
4. Adjust `itemCount` in the example to stress-test virtualization, then re-run to compare.

For automated measurement, integrate with `devtools_benchmarks` or the Observatory service to stream frame metrics.
