import 'package:code_base_riverpod/core/config/environment.dart';
import 'package:code_base_riverpod/core/router/app_router.dart';
import 'package:code_base_riverpod/core/theme/app_inset.dart';
import 'package:code_base_riverpod/core/widgets/custom_gallery_widget/gallery_widget.dart';
import 'package:code_base_riverpod/core/widgets/custom_gallery_widget/media_viewer.dart';
import 'package:code_base_riverpod/core/widgets/custom_image_widget/custom_image_widget.dart';
import 'package:code_base_riverpod/core/widgets/input/app_text_input_variant.dart';
import 'package:code_base_riverpod/features/dashboard/presentation/widgets/dashboard_tile.dart';
import 'package:code_base_riverpod/features/dashboard/presentation/widgets/custom_widget_section.dart';
import 'package:code_base_riverpod/features/dashboard/presentation/widgets/widget_playground_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final env = EnvironmentConfig.current;
    const demoImageSources = [
      CustomImageSource.network('https://picsum.photos/id/1015/400/300'),
      CustomImageSource.network('https://picsum.photos/id/1025/400/300'),
      CustomImageSource.network('https://example.com/invalid-image.jpg'),
    ];
    const demoGalleryCarouselItems = [
      GalleryMediaItem.image(
        imageSource: CustomImageSource.network(
          'https://picsum.photos/id/1003/1024/768',
        ),
        heroTag: 'gallery-carousel-1',
      ),
      GalleryMediaItem.image(
        imageSource: CustomImageSource.network(
          'https://picsum.photos/id/1011/1024/768',
        ),
        heroTag: 'gallery-carousel-2',
      ),
      GalleryMediaItem.video(
        videoSource: GalleryVideoSource.network(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
        thumbnailSource: CustomImageSource.network(
          'https://picsum.photos/id/1043/1024/768',
        ),
        heroTag: 'gallery-carousel-video-1',
      ),
      GalleryMediaItem.image(
        imageSource: CustomImageSource.network(
          'https://picsum.photos/id/1015/1024/768',
        ),
        heroTag: 'gallery-carousel-3',
      ),
    ];
    const demoGalleryGridItems = [
      GalleryMediaItem.image(
        imageSource: CustomImageSource.network(
          'https://picsum.photos/id/1003/1024/768',
        ),
        heroTag: 'gallery-grid-1',
      ),
      GalleryMediaItem.image(
        imageSource: CustomImageSource.network(
          'https://picsum.photos/id/1011/1024/768',
        ),
        heroTag: 'gallery-grid-2',
      ),
      GalleryMediaItem.video(
        videoSource: GalleryVideoSource.network(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ),
        thumbnailSource: CustomImageSource.network(
          'https://picsum.photos/id/1043/1024/768',
        ),
        heroTag: 'gallery-grid-video-1',
      ),
      GalleryMediaItem.image(
        imageSource: CustomImageSource.network(
          'https://picsum.photos/id/1015/1024/768',
        ),
        heroTag: 'gallery-grid-3',
      ),
    ];
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Widget Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme refreshed')),
                );
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Show snackbar',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Environment', style: theme.textTheme.titleLarge),
                  AppInset.gapMedium,
                  Text('Name: ${env.name}', style: theme.textTheme.bodyMedium),
                  Text(
                    'API: ${env.baseUrl}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Logging: ${env.enableLogging ? 'on' : 'off'} | Caching: ${env.enableCaching ? 'on' : 'off'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            AppInset.customGap(24),
            Text('Quick tests', style: theme.textTheme.titleMedium),
            AppInset.customGap(12),
            DashboardTile(
              title: 'Demo feature',
              subtitle: 'Navigate to the Retrofit + Riverpod sample screen',
              icon: Icons.developer_mode,
              onTap: () {
                context.push(AppRoutes.demo);
              },
            ),
            AppInset.customGap(12),
            DashboardTile(
              title: 'Demo Infinity Scroll (Grid)',
              subtitle: 'Navigate to the Retrofit + Riverpod sample screen',
              icon: Icons.developer_mode,
              onTap: () {
                context.push(AppRoutes.mediaGalleryExample);
              },
            ),
            AppInset.customGap(12),
            DashboardTile(
              title: 'Demo Infinity Scroll (List)',
              subtitle: 'Navigate to the Retrofit + Riverpod sample screen',
              icon: Icons.developer_mode,
              onTap: () {
                context.push(AppRoutes.restRepoExample);
              },
            ),
            AppInset.customGap(12),
            DashboardTile(
              title: 'Custom grid systems',
              subtitle: 'Preview flexible layout delegates with live tiles',
              icon: Icons.grid_view_rounded,
              onTap: () {
                context.push(AppRoutes.customGridsDemo);
              },
            ),
            AppInset.customGap(12),
            DashboardTile(
              title: 'Demo Upload Widget (List)',
              subtitle: 'Navigate to the Retrofit + Riverpod sample screen',
              icon: Icons.developer_mode,
              onTap: () {
                context.push(AppRoutes.uploadDemo);
              },
            ),
            AppInset.customGap(12),
            DashboardTile(
              title: 'Show dialog',
              subtitle: 'Preview default dialog styling',
              icon: Icons.chat_bubble_rounded,
              onTap: () async {
                await showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Sample dialog'),
                      content: const Text(
                        'Use this dialog to validate typography and spacing.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            AppInset.customGap(24),
            const WidgetPlaygroundPanel(),
            AppInset.customGap(24),
            CustomWidgetSection(
              children: [
                AppTextInputVariant(
                  type: TextFieldType.email,
                  label: 'Email (Optional)',
                  controller: TextEditingController(),
                ),
                AppInset.gapSmall,
                AppTextInputVariant(
                  type: TextFieldType.email,
                  controller: TextEditingController(),
                  required: true,
                ),
                AppInset.gapSmall,
                AppTextInputVariant(
                  type: TextFieldType.password,
                  controller: TextEditingController(),
                  required: true,
                ),
              ],
            ),
            AppInset.customGap(24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom image widget',
                      style: theme.textTheme.titleMedium,
                    ),
                    AppInset.customGap(12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: demoImageSources
                          .map(
                            (source) => SizedBox(
                              width: 120,
                              height: 80,
                              child: CustomImageWidget(
                                source: source,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    AppInset.gapLarge,
                    Text(
                      'Custom gallery widget',
                      style: theme.textTheme.titleMedium,
                    ),
                    AppInset.customGap(12),
                    CustomGalleryWidget(
                      items: demoGalleryCarouselItems,
                      mode: GalleryDisplayMode.carousel,
                      carouselHeight: 200,
                      showCarouselIndicator: true,
                      autoPlayVideos: false,
                      loopVideos: false,
                    ),
                    AppInset.gapLarge,
                    CustomGalleryWidget(
                      items: demoGalleryGridItems,
                      mode: GalleryDisplayMode.grid,
                      gridCrossAxisCount: 3,
                      gridSpacing: 8,
                      gridPadding: EdgeInsets.zero,
                      autoPlayVideos: false,
                      loopVideos: false,
                    ),
                  ],
                ),
              ),
            ),
            AppInset.customGap(24),
            Text('Chips and badges', style: theme.textTheme.titleMedium),
            AppInset.customGap(12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilterChip(
                  label: const Text('Selected'),
                  selected: true,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Not selected'),
                  selected: false,
                  onSelected: (_) {},
                ),
                InputChip(
                  avatar: const CircleAvatar(child: Text('A')),
                  label: const Text('Input chip'),
                  onPressed: () {},
                ),
                Chip(
                  avatar: const Icon(Icons.info, size: 18),
                  label: const Text('Info chip'),
                ),
                Badge(
                  label: const Text('5'),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  ),
                ),
              ],
            ),
            AppInset.customGap(24),
            Text('Cards', style: theme.textTheme.titleMedium),
            AppInset.customGap(12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.palette,
                                size: 48,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Primary card',
                                  style: theme.textTheme.titleMedium,
                                ),
                                AppInset.gapMedium,
                                Text(
                                  'Tap to verify ripple and elevation interactions.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: theme.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: theme.textTheme.titleMedium,
                          ),
                          AppInset.gapLarge,
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Users',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                    Text(
                                      '1,245',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sessions',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                    Text(
                                      '3,982',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          AppInset.gapLarge,
                          FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Refresh metrics'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppInset.customGap(48),
          ],
        ),
      ),
    );
  }
}
