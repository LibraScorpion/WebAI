import 'package:flutter/material.dart';
import 'error_widget.dart';
import 'empty_state.dart';
import 'shimmer_loading.dart';

class ExampleUsage extends StatelessWidget {
  const ExampleUsage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Usage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Error Widget Examples
          const Text('Error Widget Examples:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const CustomErrorWidget(
            message: 'Something went wrong',
            details: 'Please try again later',
            icon: Icons.error_outline,
          ),
          const SizedBox(height: 16),
          const NoConnectionWidget(
            details: 'Check your internet connection',
          ),
          const SizedBox(height: 24),

          // Empty State Examples
          const Text('Empty State Examples:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const EmptyChat(),
          const SizedBox(height: 16),
          const EmptySearch(),
          const SizedBox(height: 24),

          // Shimmer Loading Examples
          const Text('Shimmer Loading Examples:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ShimmerLoading(
              child: Column(
                children: [
                  const ShimmerContainer(
                    width: double.infinity,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: ShimmerContainer(
                          height: 120,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: ShimmerContainer(
                          height: 120,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: 200,
            child: ShimmerList(
              itemCount: 3,
              itemHeight: 60,
            ),
          ),
        ],
      ),
    );
  }
}

// Example of using ErrorBoundary
class ErrorBoundaryExample extends StatelessWidget {
  const ErrorBoundaryExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorBuilder: (error, stackTrace) {
        return CustomErrorWidget(
          message: 'An error occurred',
          details: error.toString(),
          onRetry: () {
            // Handle retry logic
          },
        );
      },
      child: const YourWidget(), // Replace with your actual widget
    );
  }
}

// Placeholder widget for the example
class YourWidget extends StatelessWidget {
  const YourWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
