import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/image_model.dart';
import '../../state/image_provider.dart';
import '../../widgets/common_widgets/loading_overlay.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageHistoryPage extends StatelessWidget {
  const ImageHistoryPage({super.key});

  Future<void> _shareImage(BuildContext context, GeneratedImage image) async {
    try {
      // Download image
      final response = await http.get(Uri.parse(image.url));
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/image.png');
      await file.writeAsBytes(response.bodyBytes);

      // Share image
      await Share.shareFiles(
        [file.path],
        text: 'Generated with prompt: ${image.prompt}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Images'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                    'Are you sure you want to clear all generated images?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ImageGenerationProvider>().clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ImageGenerationProvider>(
        builder: (context, imageProvider, child) {
          if (imageProvider.isLoading) {
            return const LoadingOverlay(
              isLoading: true,
              child: SizedBox(),
            );
          }

          if (imageProvider.images.isEmpty) {
            return const Center(
              child: Text('No generated images yet'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: imageProvider.images.length,
            itemBuilder: (context, index) {
              final image = imageProvider.images[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(image.url),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(image.prompt),
                            ),
                            ButtonBar(
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () => _shareImage(context, image),
                                  child: const Text('Share'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        image.url,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            image.prompt,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
