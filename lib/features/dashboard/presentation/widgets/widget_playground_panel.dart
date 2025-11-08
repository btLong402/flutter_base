import 'package:flutter/material.dart';

class WidgetPlaygroundPanel extends StatefulWidget {
  const WidgetPlaygroundPanel({super.key});

  @override
  State<WidgetPlaygroundPanel> createState() => _WidgetPlaygroundPanelState();
}

class _WidgetPlaygroundPanelState extends State<WidgetPlaygroundPanel> {
  bool _flag = true;
  double _progress = 0.4;
  double _sliderValue = 32;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Widget playground',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _progress = (_progress + 0.2).clamp(0.0, 1.0);
                    });
                  },
                  child: const Text('Filled'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _progress = 0;
                    });
                  },
                  child: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sample snackbar')),
                    );
                  },
                  child: const Text('Text button'),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _flag = !_flag;
                    });
                  },
                  icon: Icon(_flag ? Icons.visibility : Icons.visibility_off),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable feature'),
              value: _flag,
              onChanged: (value) {
                setState(() {
                  _flag = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Slider(
              min: 4,
              max: 72,
              divisions: 17,
              value: _sliderValue,
              label: '${_sliderValue.toInt()}px',
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Type to preview',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.titleMedium!.copyWith(
                fontSize: _sliderValue,
                fontWeight: FontWeight.w600,
              ),
              child: Text(
                _controller.text.isEmpty ? 'Preview' : _controller.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
