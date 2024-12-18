import 'package:flutter/material.dart';
import 'animated_list_item.dart';
import 'page_transitions.dart';

class TransitionsExample extends StatelessWidget {
  const TransitionsExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transitions Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Animated List Example
          const Text('Animated List Example:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: AnimatedListView(
              children: List.generate(
                5,
                (index) => Card(
                  child: ListTile(
                    title: Text('Item ${index + 1}'),
                    subtitle: Text('Subtitle ${index + 1}'),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Animated Grid Example
          const Text('Animated Grid Example:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: AnimatedGridView(
              crossAxisCount: 2,
              children: List.generate(
                6,
                (index) => Card(
                  child: Center(
                    child: Text(
                      'Grid Item ${index + 1}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Page Transition Examples
          const Text('Page Transition Examples:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _showTransitionPage(
                  context,
                  SlideDirection.right,
                ),
                child: const Text('Slide Right'),
              ),
              ElevatedButton(
                onPressed: () => _showFadeTransitionPage(context),
                child: const Text('Fade'),
              ),
              ElevatedButton(
                onPressed: () => _showScaleTransitionPage(context),
                child: const Text('Scale'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransitionPage(BuildContext context, SlideDirection direction) {
    Navigator.push(
      context,
      SlidePageRoute(
        page: const _DemoPage(title: 'Slide Transition'),
        direction: direction,
      ),
    );
  }

  void _showFadeTransitionPage(BuildContext context) {
    Navigator.push(
      context,
      FadePageRoute(
        page: const _DemoPage(title: 'Fade Transition'),
      ),
    );
  }

  void _showScaleTransitionPage(BuildContext context) {
    Navigator.push(
      context,
      ScalePageRoute(
        page: const _DemoPage(title: 'Scale Transition'),
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  final String title;

  const _DemoPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
